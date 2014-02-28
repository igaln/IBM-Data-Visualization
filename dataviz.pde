//  IBM DATA VIZ CODE ALPHA 
//  IGAL NASSIMA
//  2012
//
//  TEST VALUES
//  PVector p = mercatorToPixel(new PVector(0.8, 51.5));       // London
//  PVector n = mercatorToPixel(new PVector(-73.9, 40.8));     // New York
//  PVector n2 = mercatorToPixel(new PVector(-74.3, 41.2));     // New York 2
//  PVector las = mercatorToPixel(new PVector(-113.9, 30.8));   // LA
//  PVector t = mercatorToPixel(new PVector(139.8, 35.7));     // Tokyo
//  PVector s = mercatorToPixel(new PVector(151.0, -34.0));       // Sydney
//  PVector ist = mercatorToPixel(new PVector(28.974,41.0128)); 
//
//  PVector south = mercatorToPixel(new PVector(-113.9, -30.8));   // LA
//
//  sources.add(p);   
//  ArrayList dest0 = new ArrayList<PVector>();
//  dest0.add(n);
//  dest0.add(las);
//  dest0.add(s);
//  dest0.add(t);
//  dest0.add(ist);
//  destinations.add(dest0);


import org.json.*;

import processing.opengl.*;
import processing.pdf.*;
import java.util.List;
import java.lang.Math;

String loadedFile;
JSONObject usr_list;
JSONObject raw_data;

int currentCompany = 0;
String path = "JSONS/";
String mapfile = "/datamapped.json";

String[] companies = {
  "Havas",
"Ginny",
"Oracle",
"IBM",
"ATCO",
"ATL",
"ATT",
"Alcoa",
"Amgen",
"AngloAmerican",
"Avon",
"Bechtel",
"Boeing",
"CVS",
"CardinalHealth",
"Cargil",
"CherninAll",
"Chevron",
"Cintas",
"DowChemical",
"GM",
"GreenDiamond",
"HCA",
"HomeDepot",
"LizClaiborne",
"Macys",
"Medtronic",
"Motorola",
"Nalco",
"Nielsen",
"NorfolkSouthern",
"NorthropGrumman",
"OracleTxt",
"ProcterGamble",
"Samsung",
"SocialBusiness",
"Sun",
"YumBrands"};

PImage backgroundMap;
float mapScreenWidth, mapScreenHeight;  // Dimension of map in pixels.

PVector start, end, cpoint;
PVector[] route;
P_BezierSpline spline;
aTileSaver tiler;  

List<P_BezierSpline> data;
List<PVector> sources;
List<ArrayList> destinations;

// HEATMAP

PImage heatmapColors; // single line bmp containing the color gradient for the finished heatmap, from cold to hot
PImage heatmap; // canvas for the heatmap
PImage heatmapBrush; // radial gradient used as a brush. Only the blue channel is used.
PImage gradientMap; // canvas for the intermediate map
float maxValue = 0; // variable storing the current maximum value in the gradientMap
PImage dotdot;
PShape dot;



public JSONObject get_array() {
  try {
    
    println("get total json from " + path + companies[currentCompany] + "/" + companies[currentCompany] + "_Total.json");
    
    loadedFile = join(loadStrings(path + companies[currentCompany] + "/" + companies[currentCompany] + "_Total.json"), " ");
    
    usr_list = new JSONArray ( loadedFile ).getJSONObject(0);
    
    
  } 
  catch (Exception e) {
    e.printStackTrace();
  }
  return usr_list;
}

public void get_raw_data() {
  try {
    println("get data map from " + path + companies[currentCompany] + mapfile);
    loadedFile = join(loadStrings(path + companies[currentCompany] + mapfile ), " ");
    raw_data = new JSONArray(loadedFile ).getJSONObject(0);
    
  } 
  catch (Exception e) {
    e.printStackTrace();
  }

}

public JSONObject[] get_objects(){

           get_array();
          

          return null;
}

public PVector find_latlon (String userid) {
   
    
    JSONObject temp2;
    PVector latlon;
    try {
       temp2 = usr_list.getJSONObject(userid);
         double lat = temp2.getDouble("lat");
        double lon = temp2.getDouble("lon");
        latlon = new PVector((float)lon,(float)lat);
  
         return latlon;
    } 
      catch (Exception e) {
           e.printStackTrace();
           println("cant find name");
      }
     
     
      return null;
   
}

void drawGradient(float x, float y) {
  int a = 0;  
  for (int r = 5; r > 0; --r) {
    fill(r, a);
    ellipse(x, y, r, r);
    a = a + 3;
  }
}

void setup()
{
  
    double W = 2850;
   double H = 2123.794;

 size(12000,8943);
 
  background(255, 255, 255);
 
  smooth();
  ellipseMode(RADIUS);
 
  get_objects();
   get_raw_data();
  

  backgroundMap   = loadImage("masterMapedited.jpg");
  dotdot = loadImage("bigdot.png");
  dot = loadShape("dotdot.svg");
  heatmapColors = loadImage("images/heatmapColors2.png");
  heatmapBrush = loadImage("images/heatmapBrush.png");

  
  mapScreenWidth  = width;
  mapScreenHeight = height;
  data = new ArrayList<P_BezierSpline>();
  sources = new ArrayList<PVector>();
  destinations = new ArrayList<ArrayList>();

   tiler=new aTileSaver(this);

  heatmap = new PImage(width, height);
  gradientMap = new PImage(width, height);
  // load pixel arrays for all relevant images

  heatmap.loadPixels();
  heatmapBrush.loadPixels();
  heatmapColors.loadPixels();

  
   JSONArray namelist = raw_data.names();

   for (int datalen = raw_data.length(), k = 0; k < datalen; k++) {
     
     String tkey = "";
     PVector sourcedata;
     try {
        tkey = namelist.getString(k);
     }
     
      catch (JSONException e) {
          e.printStackTrace();
    }
    
    if(tkey != "") {
      if(find_latlon(tkey) != null) {
        sourcedata = mercatorToPixel(find_latlon(tkey));
        sources.add(sourcedata); 
        ArrayList destinationdata = new ArrayList<PVector>();
        
        try {
          JSONArray destinations = raw_data.getJSONArray(tkey);
          
          for (int destlen = destinations.length(), j = 0; j < destlen; j++) {
            
                 try {
                        tkey = destinations.getString(j);
                        
                         if(find_latlon(tkey) != null) {
                              PVector destdata = mercatorToPixel(find_latlon(tkey));
                              //println(sourcedata);
                              destinationdata.add(destdata); 
                              
                         }
                        
                     }
                     
                      catch (JSONException e) {
                        println("cannot find json key");
                        //  e.printStackTrace();
                    }
            
          }
          
         // println(destinations);
          
        }  catch (Exception e) {
          e.printStackTrace();
        }
        
        
        destinations.add(destinationdata);
        
      }
    }
     
   }

    image(backgroundMap,0,0,width,height);
  for (int len = sources.size(), i = 0; i < len; i++) {
    //String s = myList.get(i);

    ArrayList <PVector>destList = destinations.get(i);
    PVector source_target = sources.get(i);
    //println("source " + source_target + " dest length " + destList);


    
    noStroke();
    drawGradient(source_target.x,source_target.y);

    if ( destList.size() > 0) {
      
      for (int len2 = destList.size(), z = 0; z < len2; z++) {
        
        PVector dest_target = destList.get(z);
          drawGradient(dest_target.x,dest_target.y);
        
        if (Math.abs(source_target.x - dest_target.x) < (width/2)) {

          // float bend_coeff = map(value, start1, stop1, start2, stop2)
          
          float curveC = random(0.15, 0.25);
          if (source_target.x < dest_target.x) {
            
            if (source_target.y < (height/2) ) {
              cpoint = calcCcurvePoint(-curveC, source_target, dest_target);
            } 
            else {
              cpoint = calcCcurvePoint(curveC, source_target, dest_target);
            }
          } 
          else {

            if (source_target.y < (height/2) ) {
              cpoint = calcCcurvePoint(-curveC, dest_target, source_target);
            } 
            else {
              cpoint = calcCcurvePoint(curveC, dest_target, source_target);
            }
          }


          route = new PVector[] { 
            source_target, cpoint, dest_target
          };
          spline = new P_BezierSpline(route);
          data.add(spline);
        } 
        else {

          PVector v0_off;
          PVector v1_off;

          if (source_target.x < dest_target.x) {
            v0_off = new PVector(source_target.x+width, source_target.y);
            v1_off = new PVector(dest_target.x-width, dest_target.y);
          } 
          else {

            v0_off = new PVector(source_target.x-width, source_target.y);
            v1_off = new PVector(dest_target.x+width, dest_target.y);
          }

           float curveC = random(0.15, 0.25);
          if (source_target.x < v1_off.x) {
            cpoint = calcCcurvePoint(-curveC, source_target, v1_off);
          } 
          else {
            cpoint = calcCcurvePoint(curveC, source_target, v1_off);
          }

          route = new PVector[] { 
            source_target, cpoint, v1_off
          };
          spline = new P_BezierSpline(route);
          data.add(spline);

           curveC = random(0.15, 0.25);
          if (source_target.x < v0_off.x) {
            cpoint = calcCcurvePoint(-curveC, dest_target, v0_off);
          } 
          else {
            cpoint = calcCcurvePoint(curveC, dest_target, v0_off);
          }

          route = new PVector[] { 
            dest_target, cpoint, v0_off
          };
          spline = new P_BezierSpline(route);
          data.add(spline);
        }
      } //for
    }
  }
  
  
  
    for (int len = sources.size(), i = 0; i < len; i++) {

    PVector source_target = sources.get(i);

    // updateHeatMap(source_target);
  }
  //fill(0, 0, 255);
  //blendMode(DIFFERENCE);
  smooth();
 // stroke(84, 40, 14, 100);
  stroke(255, 0, 0, 100);
  strokeWeight(0.1);
  noFill();


  for (int len = data.size(), i = 0; i < len; i++) {
    //String s = myList.get(i);
     P_BezierSpline temp_spline = data.get(i);
   drawSpline(temp_spline);
  }
  
  
  
}

void draw()
{
  //background(0);

if(tiler==null) return; // Not initialized  
    
  // call aTileSaver.pre() to prepare frame and setup camera if it exists.  
  tiler.pre();  
  
  // call aTileSaver.post() to update tiles if tiler is active  
  tiler.post();  
  //println("Finished.");

}


public void updateHeatMap(PVector loc) {
  smooth();
  // render the heatmapBrush into the gradientMap:
  tilesnResolution((int)loc.x, (int)loc.y);
  // update the heatmap from the updated gradientMap:
  updateHeatmap();
  //image(heatmap, 0, 0);
  image(gradientMap, 0, 0);

}

//// Converts screen coordinates into geographical coordinates. 
//// Useful for interpreting mouse position.
//public PVector pixelToGeo(PVector screenLocation)
//{
//  //return new PVector(mapGeoLeft + (mapGeoRight-mapGeoLeft)*(screenLocation.x)/mapScreenWidth, 
//  //mapGeoTop - (mapGeoTop-mapGeoBottom)*(screenLocation.y)/mapScreenHeight);
//  return ni
//}


public PVector mercatorToPixel (PVector geoLocation) {
  
    //double W = 9000;
    //double H = 6706.719;
   //size(12000,8943);
   
    double W = 12000;
    double H = 8943;
    


   double CENTRAL_MERIDIAN_OFFSET = 0.18;
   double x, y;

    double lon =  Math.toRadians(geoLocation.x);
    double lat =  Math.toRadians(geoLocation.y);

    x = lon - CENTRAL_MERIDIAN_OFFSET;
    y = 1.25 * Math.log( Math.tan( 0.25 * Math.PI + 0.4 * lat ) );

    x = ( W / 2 ) + ( W / (2 * Math.PI) ) * x;
    y = ( H / 2 ) - ( H / ( 2 * 2.203412543 ) ) * y;

    y -= 9;

  
  return new PVector((float)x,(float)y);
  

}




void drawSpline(P_BezierSpline temp_spline) {
  float t = 0, dt = 0.001;
  PVector last, curr;


  last = temp_spline.point(t);
  for (t = dt; t <= 1; t += dt) {
    curr = temp_spline.point(t);
    line(last.x, last.y, curr.x, curr.y);
    last = curr;
    //curveVertex( curr.x, curr.y);
  }
}

// bend controls how far the curve point is from the line joining
// the two points v0 and v1
PVector  calcCcurvePoint(float bend, PVector v0, PVector v1) {

  //  println(v0.x);
  //  println(v1.x);    
  //  println("diff is " + Math.abs(v0.x - v1.x));

  // Calculate mid point between cities
  PVector v = PVector.sub(v1, v0);
  PVector mid = PVector.div(v, 2);
  mid.add(v0);
  // Get normal to line between cities
  PVector n = new PVector(-v.y, v.x, 0);
  n.normalize();
  // Rescale and translet n to give third point for Bezier spline
  n. mult(bend * v.mag());
  n.add(mid);
  return n;
}



/*
Rendering code that blits the heatmapBrush onto the gradientMap, centered at the specified pixel and drawn with additive blending
 */
void tilesnResolution(int x, int y)
{

  // find the top left corner coordinates on the target image
  int startX = x-heatmapBrush.width/2;
  int startY = y-heatmapBrush.height/2;

  for (int py = 0; py < heatmapBrush.height; py++)
  {
    for (int px = 0; px < heatmapBrush.width; px++) 
    {
      // for every pixel in the heatmapBrush:

      // find the corresponding coordinates on the gradient map:
      int hmX = startX+px;
      int hmY = startY+py;
      /*
      The next if-clause checks if we're out of bounds and skips to the next pixel if so.
       
       Note that you'd typically optimize by performing clipping outside of the for loops!
       */
      if (hmX < 0 || hmY < 0 || hmX >= gradientMap.width || hmY >= gradientMap.height)
      {
        continue;
      }

      // get the color of the heatmapBrush image at the current pixel.
      int col = heatmapBrush.pixels[py*heatmapBrush.width+px]; // The py*heatmapBrush.width+px part would normally also be optimized by just incrementing the index.
      col = col & 0xffffff; // This eliminates any part of the heatmapBrush outside of the blue color channel (0xff is the same as 0x0000ff)

      // find the corresponding pixel image on the gradient map:
      int gmIndex = hmY*gradientMap.width+hmX;

      if (gradientMap.pixels[gmIndex] < 0xffffff-col) // sanity check to make sure the gradient map isn't "saturated" at this pixel. This would take some 65535 clicks on the same pixel to happen. :)
      {
        gradientMap.pixels[gmIndex] += col; // additive blending in our 24-bit world: just add one value to the other.
        if (gradientMap.pixels[gmIndex] > maxValue) // We're keeping track of the maximum pixel value on the gradient map, so that the heatmap image can display relative click densities (scroll down to updateHeatmap() for more)
        {
          maxValue = gradientMap.pixels[gmIndex];
        }
      }
    }
  }
  gradientMap.updatePixels();
  //gradientMap = blurImage(gradientMap);
}

/*
Updates the heatmap from the gradient map.
 */
void updateHeatmap()
{
  // for all pixels in the gradient:
  for (int i=0; i<gradientMap.pixels.length; i++)
  {
    // get the pixel's value. Note that we're not extracting any channels, we're just treating the pixel value as one big integer.
    // cast to float is done to avoid integer division when dividing by the maximum value.
    float gmValue = gradientMap.pixels[i];

    // color map the value. gmValue/maxValue normalizes the pixel from 0...1, the rest is just mapping to an index in the heatmapColors data.
    int colIndex = (int) ((gmValue/maxValue)*(heatmapColors.pixels.length-1));
    int col = heatmapColors.pixels[colIndex];

    // update the heatmap at the corresponding position
    heatmap.pixels[i] = col;
  }
  // load the updated pixel data into the PImage.
  heatmap.updatePixels();
}



// Saves tiled imaged when 't' is pressed  
public void keyPressed() {  
  if(key=='t') tiler.init("Simple"+nf(frameCount,5),5); 
 if (key == 'a') {
save("VIZ2/" + companies[currentCompany] +  nf(frameCount,5)+ "picture.png");  // whole screen of program
 }  
else if (key == 'p') {   // just a certain part definded by a rect - see reference on rect (x,y,width, height);
PImage cp = get (500, 500, 2616, 1700);
cp.save(nf(frameCount,5)+"pictureP.tif");
}
}  
