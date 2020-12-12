import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tsp_visualiser/canvasDraw.dart';

class paint extends StatefulWidget {
  @override
  _paintState createState() => _paintState();
}
List<List<double>> cities=[];
List<List<double>> citiespt=[];
List<List<double>> graph= [];
double cost=double.maxFinite;

int nocities=10;
List<int> visited_cities=List.filled(nocities, 0);
List<List<int>> population=[];
int noPopulation=500;
int generations=150;
List<double> fitness=[];
List<int> bestEver=[];
double recordDistance=double.maxFinite;
class _paintState extends State<paint>{

  Random random=Random();
  bool isSorting=false,isdesktop=false,iscancelled=false,_validate=false;
  int isselected=1;
  double delay=3000;
  String message="";
  double wid = double.infinity;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _textEditingController=TextEditingController(text: nocities.toString());
  TextEditingController _textEditingController2=TextEditingController(text: noPopulation.toString());
  TextEditingController _textEditingController3=TextEditingController(text: generations.toString());

  List<ListItem> _dropdownItems = [
    ListItem(1, "Genetic Algorithm"),
    ListItem(2, "Backtracking Algorithm"),
    ListItem(3, "Nearest Insertion"),
    ListItem(4, "Greedy Algorithm")
  ];

  List<DropdownMenuItem<ListItem>> _dropdownMenuItems;
  ListItem _selectedItem;

  void repaint() async {
    await Future.delayed(Duration(milliseconds: 3000 - delay.toInt()));
    cities.shuffle();
    setState(() {

    });
  }


  void creategraph() {
    for (int fromNode = 0; fromNode < citiespt.length; fromNode++) {
      List<double> temp=List.filled(citiespt.length, 0);
      graph.add(temp);
      for (int toNode = 0; toNode < citiespt.length; toNode++) {
        if (fromNode != toNode)
          graph[fromNode][toNode] = double.parse(sqrt(pow(citiespt[toNode][0] - citiespt[fromNode][0],2) + pow(citiespt[toNode][1] - citiespt[fromNode][1],2)).toStringAsFixed(2));
      }
    }
    //print(graph);
  }



void shuffle(){
  citiespt=[];
  cities=[];
  visited_cities=List.filled(nocities, 0);
  cost=double.maxFinite;
  setState(() {

  });
  int wi=400;
  if(isdesktop)
    wi=900;
  for (var i = 0; i < nocities; i++)
  {
    List<double> v = [ Random().nextInt(wi).toDouble(), Random().nextInt(500).toDouble()];
    citiespt.add(v);
  }

  graph=[];
  creategraph();
  setState(() {

  });
}


  @override
  void initState() {

    int wi=400;
    if(isdesktop)
      wi=900;
    for (var i = 0; i < nocities; i++)
    {
      List<double> v = [ Random().nextInt(wi).toDouble(), Random().nextInt(500).toDouble()];
      citiespt.add(v);
    }
    creategraph();
    _dropdownMenuItems = buildDropDownMenuItems(_dropdownItems);
    _selectedItem = _dropdownMenuItems[0].value;

    super.initState();
  }
  List<DropdownMenuItem<ListItem>> buildDropDownMenuItems(List listItems) {
    List<DropdownMenuItem<ListItem>> items = List();
    for (ListItem listItem in listItems) {
      items.add(
        DropdownMenuItem(
          child: Text(listItem.name),
          value: listItem,
        ),
      );
    }
    return items;
  }


  @override
  Widget build(BuildContext context) {

    double wid = MediaQuery
        .of(context)
        .size
        .width;

    if (wid > 500) {
      isdesktop = true;
      wid = 420;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("TSP Visualizer"),
        centerTitle: true,
        leading:isdesktop ? Container():GestureDetector(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.menu),//AnimatedIcon(icon: AnimatedIcons.menu_arrow,progress: _animationController,),
          ),
          onTap: (){
            _scaffoldKey.currentState.openDrawer();
          },
        ),
      ),
      key: _scaffoldKey,
      drawer: getDrawer(),
      body: Row(
        children: [
          isdesktop?getDrawer():Container(),
          Expanded(
            child: Column(

              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(height: 10,),

              Text(_selectedItem.name,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                SizedBox(height: 5,),
                Container(
                  margin: EdgeInsets.all(0),
                  padding: EdgeInsets.all(0),
                  color: Colors.black26,
                  height: isdesktop? 530:400,
                  width: isdesktop?1000:double.infinity,
                  child: CustomPaint(painter: FaceOutlinePainter(citiespt: citiespt,cities: cities),),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10,),


               isdesktop? Container():bottombuttons(),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget bottombuttons() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          FloatingActionButton.extended(
            icon:isSorting? Icon(Icons.stop):Icon(Icons.play_arrow),
            onPressed:isSorting?(){
              setState(() {
                iscancelled=true;
              });
            } :()async {
              setState(() {
                isSorting=true;
                cost=double.maxFinite;
              });
              if(isselected==1)
                await startgenetic();
              else if(isselected==2)
                await starttspback();
              else if(isselected==3)
                await start();
              else if(isselected==4)
                await startgreedy();
              setState(() {
                isSorting=false;
              });
            },
            label:isSorting? Text('Stop'):Text('Start'),

          ),

          FloatingActionButton.extended(
            elevation: 5,
            tooltip: 'Shuffle points',
            backgroundColor:isSorting? Colors.grey:Colors.blue,
            icon: Icon(Icons.shuffle),
            onPressed:isSorting? null: () {
              citiespt=[];
              cities=[];
              visited_cities=List.filled(nocities, 0);
              cost=double.maxFinite;
              setState(() {

              });
              int wi=400;
              if(isdesktop)
                wi=790;
              for (var i = 0; i < nocities; i++)
              {
                List<double> v = [ Random().nextInt(wi).toDouble(), Random().nextInt(400).toDouble()];
                citiespt.add(v);
              }

                graph=[];
                creategraph();
                setState(() {

                });
            },
            label: Text('Shuffle'),
          ),
        ],
      ),
    );
  }



//----------------------------------------Genetic Algorithm-------------------------------------
  //--------------------------------------------------------------------------------------------


  void startgenetic() async{
    recordDistance=double.infinity;
    bestEver=[];
    population=[];
    await setup();
    for(int i=0;i<generations;i++)
    {
      if(iscancelled)
        break;
      await calculateFitness();
      //await normalizeFitness();
      //print(fitness);
      await nextGeneration();
      await add(bestEver);
      //print(bestEver);
      setState(() {
        message="Distance="+recordDistance.toStringAsFixed(2)+" Generation="+i.toString();
      });

      //print(recordDistance);
     // print(population);
    }
    cost=calcDistance(citiespt,bestEver);
    setState(() {
      message="Cost"+cost.toStringAsFixed(2);
    });
    if(iscancelled)
      {
        setState(() {
          iscancelled=false;
        });
      }

  }


  void setup() {
    List<int> order = [];
    for (var i = 0; i < nocities; i++) {
      order.add(i);
    }
    for (var i = 0; i < noPopulation; i++) {
      population.add(order.toList());
      order.shuffle();

    }
  }

  double calcDistance(points, order) {
    double sum = 0;
//    for (int i = 0; i < order.length - 1; i++) {
//      int cityAIndex = order[i];
//      List<double> cityA = points[cityAIndex];
//      int cityBIndex = order[i + 1];
//      List<double> cityB = points[cityBIndex];
//      double d=(sqrt(pow(cityA[0] - cityB[0],2) + pow(cityA[1] - cityB[1],2)));
//      sum += d;
//    }
    int frompt=order[0];
    for(int i=0;i<order.length;i++)
      {
        sum+=graph[frompt][order[i]];
        frompt=order[i];
      }
    return sum;
  }

  void calculateFitness() async{
    double currentRecord = double.maxFinite;
    for (int i = 0; i < population.length; i++) {
      double d = calcDistance(citiespt, population[i]);
      if (d < recordDistance) {
        recordDistance = d;
        bestEver = population[i].toList();
        await add(bestEver);
      }
//      if (d < currentRecord) {
//        currentRecord = d;
//        currentBest = population[i].toList();
//        //await add(currentBest);
//      }
      fitness.add(d);
    }
  }

  void add(order) async{
    cities=[];
    for(int i=0;i<order.length;i++)
    {
      cities.add(citiespt[order[i]]);
    }
    setState(() {

    });
    await Future.delayed(Duration(milliseconds: 3000 - delay.toInt()));
  }


  void nextGeneration() {
    List<List<int>> newPopulation = [];
    List<double> temp=fitness.toList();
    List<double> temp2=fitness.toList();
    List<double> fitness2=[];
    temp.sort();
    for(int i=0;i<150;i++)
    {
      int ind=temp2.indexOf(temp[i]);
      fitness2.add(temp[i]);
      temp2[ind]=-1;
      newPopulation.add(population[ind]);
    }
    //fitness=fitness2.toList();
    fitness=[];
    List<List<int>> children=[];
    for(int i=1;i<newPopulation.length;i++)
      children.add(crossOver(newPopulation[i-1], newPopulation[i]));
    for(int i=0;i<children.length;i++)
      children[i]=mutate(children[i], 0.01);
    newPopulation.addAll(children);
    population=newPopulation.toList();
//    for (int i = 0; i < population.length; i++) {
//      List<int> orderA = pickOne(population, fitness);
//      List<int> orderB = pickOne(population, fitness);
//      List<int> order = crossOver(orderA, orderB);
//
//      mutate(order, 0.01);
//      newPopulation.add(orderA.toList());
//    }
//    population = newPopulation.toList();
  }
  List<int> crossOver(orderA, orderB) {
    var start = random.nextInt(orderA.length-1);
    //var end = random.nextInt(start + 1, orderA.length);
    var end =start+1+random.nextInt(orderA.length-start-1);
    List<int> neworder = orderA.sublist(start,end);
    // var left = totalCities - neworder.length;
    for (var i = 0; i < orderB.length; i++) {
      var city = orderB[i];
      if (!neworder.contains(city)) {
        neworder.add(city);
      }

    }

    return neworder;
  }
  List<int> mutate(orderA, mutationRate) {
    for (var i = 0; i < nocities; i++) {
      if (random.nextDouble() < mutationRate) {
        var indexA = random.nextInt(orderA.length);
        var indexB = (indexA + 1) % nocities;
        swap(orderA, indexA, indexB);
      }
    }
    return orderA;
  }

  void swap(a, i, j) {
    var temp = a[i];
    a[i] = a[j];
    a[j] = temp;
  }


  List<int> pickOne(list, List<double>prob) {
    int index = 0;

    double r=random.nextDouble();
    double mi=prob[0];
    List<double> temp=prob.toList();
    for(int i=0;i<prob.length;i++)
      mi=min(mi,prob[i]);
    while (r > 0) {
      r = r - prob[index];
      index++;
    }
    index--;

    return list[index].toList();
  }






//------------------------Nearest Insertion--------------------------------------------
  //--------------------------------------------------------------------------------------

  Future<int> tsp(int c) async
  {
    int i,nc=99999;
    double min=99999,kmin;

    for(i=0;i < nocities;i++)
    {
      if(iscancelled)
        break;
      if((graph[c][i]!=0)&&(visited_cities[i]==0))

        if(graph[c][i]+graph[i][c] < min)
        {
          min=graph[i][0]+graph[c][i];
          kmin=graph[c][i];
          nc=i;
        }
    }

    if(min!=99999)
      cost+=kmin;

    return nc;
  }

  void minimum_cost(int city) async
  {
    int i,ncity;

    visited_cities[city]=1;
    if(iscancelled)
      return;
    await Future.delayed(Duration(milliseconds: 3000 - delay.toInt()));
    //print(city+1);
    ncity= await tsp(city);

    if(ncity==99999)
    {

      ncity=0;
      print(ncity+1);
      cost+=graph[city][ncity];

      return;
    }

    cities.add(citiespt[ncity]);
    setState(() {

    });


    await minimum_cost(ncity);
  }

  void start() async{
    cost=0;
    cities=[];
    cities.add(citiespt[0]);
    await minimum_cost(0);
    cities.add(citiespt[0]);
    setState(() {

    });
    await Future.delayed(Duration(milliseconds: 3000 - delay.toInt()));
    print('cost='+cost.toStringAsFixed(2));
    if(iscancelled)
    {
      setState(() {
        iscancelled=false;
      });
    }
    setState(() {
      message='Cost='+cost.toStringAsFixed(2);
    });
  }


  //-----------------------------------Backtracking----------------------------------------------------
  //---------------------------------------------------------------------------------------------------
  void starttspback() async{
    cost=double.maxFinite;
    visited_cities=List.filled(nocities, 0);
    cities.add(citiespt[0]);
    visited_cities[0]=1;
    List<List<int>> tm=[];
    List<double> cstlist=[];
    await tspback(0, 1, 0,[],tm,cstlist);
    print("cost"+cost.toString());
    int ind=cstlist.indexOf(cost);
    for(int i=0;i<tm[ind].length;i++)
      cities.add(citiespt[tm[ind][i]]);
    cities.add(citiespt[0]);
    setState(() {

    });
    if(iscancelled)
    {
      setState(() {
        iscancelled=false;
      });
    }
    setState(() {
      message='Cost='+cost.toStringAsFixed(2);
    });
  }

  void tspback(int currPos, int count, double cos,List<int> path,List<List<int>> tm,List<double> cstlist) async
  {
    if (count == nocities && graph[currPos][0]!=0)
    {
      if( cos + graph[currPos][0]<=cost)
        {
          cost= cos + graph[currPos][0];
          cstlist.add(cost);
          //print(path);
          tm.add(path.sublist(0));
          cities.add(citiespt[0]);
          setState(() {

          });
          await Future.delayed(Duration(milliseconds: 3000 - delay.toInt()));
          cities.removeLast();
        }
      //cost = min(cost, cos + graph[currPos][0]);
      return;
    }

    await Future.delayed(Duration(milliseconds: 3000 - delay.toInt()));
    for (int i = 0; i < nocities; i++)
    {
      if(iscancelled)
        break;
      //print(currPos);
      if (visited_cities[i]==0 && graph[currPos][i]!=0)
      {
        if(iscancelled)
          break;

      // Mark as visited
        visited_cities[i] = 1;
        cities.add(citiespt[i]);
        setState(() {

        });
        path.add(i);

        await tspback(i,count + 1, cos + graph[currPos][i],path,tm,cstlist);

        // Mark ith node as unvisited
        path.removeLast();
        cities.removeLast();
        setState(() {

        });
        visited_cities[i] = 0;
      }
    }
  }
  //-----------------------------------Greedy----------------------------------------------------
  //---------------------------------------------------------------------------------------------------

  void startgreedy() async{
    cities=[];
    await greedy(graph);
  }

  void greedy(tsp) async
  {
    double sum = 0;
    int counter = 0;
    int j = 0, i = 0;
    double min = double.maxFinite;
    List<int> visitedRouteList =[];

    visitedRouteList.add(0);
    List<int> route = List.filled(nocities,0);

    while (i < tsp.length && j < tsp[i].length)
    {
      if (counter >= tsp[i].length - 1)
      {
        break;
      }


      if (j != i && !(visitedRouteList.contains(j)))
      {
        if (tsp[i][j] < min)
        {
          min = tsp[i][j];
          route[counter] = j + 1;
        }
      }
      j++;


      if (j == tsp[i].length)
      {
        sum += min;
        min = double.maxFinite;
        visitedRouteList.add(route[counter] - 1);
        await add(visitedRouteList);
        j = 0;
        i = route[counter] - 1;
        counter++;
        print(visitedRouteList);
      }
    }


    i = route[counter - 1] - 1;

    for (j = 0; j < tsp.length; j++)
    {

      if ((i != j) && tsp[i][j] < min)
      {
        min = tsp[i][j];
        route[counter] = j + 1;
      }
    }
    sum += min;
    setState(() {
      message="Cost = "+sum.toStringAsFixed(2);
    });
    print(visitedRouteList);
    print("Minimum Cost is : "+sum.toStringAsFixed(2));

  }

  //---------------------------------------------------------------------------------------------------
  //---------------------------------------------------------------------------------------------------



  Widget getDrawer(){
    return Container(width: 330,
      decoration: BoxDecoration(border: Border.all(),borderRadius: BorderRadius.circular(10),color: Colors.white),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            SizedBox(height: 50,),
            TextField(decoration: InputDecoration(labelText: "No. of cities",errorText: _validate?"Enter no.":null,
              focusColor: Colors.pinkAccent,
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2.0)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.pink,width: 2.0)),
            ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                controller: _textEditingController),
            SizedBox(height: 10,),

            Text("For Genetic Algorithm"),
            SizedBox(height: 10,),
            TextField(decoration: InputDecoration(labelText: "Population",errorText: _validate?"Enter no.":null,
              focusColor: Colors.pinkAccent,
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2.0)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.pink,width: 2.0)),),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                controller: _textEditingController2),
            SizedBox(height: 10,),
            TextField(decoration: InputDecoration(labelText: "Generations",errorText: _validate?"Enter no.":null,
              focusColor: Colors.pinkAccent,
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2.0)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.pink,width: 2.0)),),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                controller: _textEditingController3),
            SizedBox(height: 10,),
            FlatButton(color: Colors.blue,child: Text('Save'),onPressed: (){setState(() {
              if(_textEditingController.text=="" || _textEditingController2.text=="" || _textEditingController3==""){
                setState(() {
                  _validate=true;
                });
              }
              else{
                nocities=int.parse(_textEditingController.text);
                noPopulation=int.parse(_textEditingController2.text);
                generations=int.parse(_textEditingController3.text);
                _validate=false;
                isdesktop?null:Navigator.pop(context);
                shuffle();
              }


            });

            },),
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 300,
                height: 50,
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: Colors.white,
                    border: Border.all()),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(

                      value: _selectedItem,
                      items: _dropdownMenuItems,
                      onChanged:isSorting? null:(value) {
                        cities=[];
                        setState(() {
                          _selectedItem = value;
                          isselected=_selectedItem.value;
                          //print(_selectedItem.name);
                        });
                        isdesktop?null:Navigator.pop(context);
                      }
                      ),
                ),
              ),
            ),
          SizedBox(height: 10,),
          Text('Speed',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
            Container(
              width: 500,
              child: Slider(
                activeColor: Colors.pinkAccent,
                label: 'Speed',
                min: 200,
                max: 3000,
                value: delay.toDouble(),
                onChanged: (double val) {
                  setState(() {
                    delay = val;
                  });
                },
              ),
            ),

            isdesktop?bottombuttons():Container(),

          ],
        ),
      ),
    );
  }
}
//class FaceOutlinePainter extends CustomPainter {
//  PointMode pt=PointMode.lines;
//
//
//  @override
//  void paint(Canvas canvas, Size size) async{
//
//    final pt=PointMode.points;
//    final paint = Paint()
//      ..color = Colors.black
//      ..strokeWidth = 4;
//    final ptclor=Paint()
//    ..color = Colors.blue
//    ..strokeWidth=8;
//
//    for(dynamic i=0;i<citiespt.length;i++)
//    {
//      canvas.drawPoints(pt,[Offset(citiespt[i][0],citiespt[i][1])],ptclor);
//      canvas.drawCircle(Offset(citiespt[i][0],citiespt[i][1]), 6, ptclor);
//    }
//    //print(cities);
//    for(dynamic i=1;i<cities.length;i++)
//    {
//      canvas.drawLine(Offset(cities[i-1][0],cities[i-1][1]),Offset(cities[i][0],cities[i][1]),paint);
//      //canvas.drawPoints(pt,[Offset(cities[i][0],cities[i][1])],ptclor);
//    }
//
//  }
//
//  @override
//  bool shouldRepaint(FaceOutlinePainter oldDelegate) => true;
//}
class ListItem {
  int value;
  String name;

  ListItem(this.value, this.name);
}