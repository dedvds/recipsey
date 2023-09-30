import 'package:flutter/material.dart';
import 'api/api_service.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe Generator',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: RecipePage(),
    );
  }
}

class Recipe {
  final String header;
  final String ingredients;
  final String steps;

  Recipe({required this.header, required this.ingredients, required this.steps});
}


class RecipePage extends StatefulWidget {
  @override
  _RecipePageState createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  final TextEditingController _controller = TextEditingController();
  final ApiService _apiService = ApiService();
  List<Recipe>? _recipes;
  bool _isLoading = false;
  int selectedServingSize = 1;


  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recipsey')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        
      child: ListView( // <-- Change this to ListView
//          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(children: [
            TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter ingredient or cuisine',
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text("Select number of people: $selectedServingSize"),
    Slider(
      value: selectedServingSize.toDouble(),
      onChanged: (double newValue) {
        setState(() {
          selectedServingSize = newValue.round();
        });
      },
      min: 1,
      max: 10,
      divisions: 9,
      label: selectedServingSize.toString(),
    ),
    SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchRecipe,
              child: Text('Generate Recipe'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, 
                backgroundColor: Colors.orange, // text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            if (_isLoading) Center(child: CircularProgressIndicator()),
          if (_recipes != null && _recipes!.isNotEmpty) ...[
  Text('Generated Recipes:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
  SizedBox(height: 10),
  ..._recipes!.map((recipe) => Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ExpansionTile(
        title: Text(recipe.header),
        subtitle: Text(
          recipe.ingredients,
          style: TextStyle(fontSize: 12),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        children: [
          ListTile(
            title: Text('Ingredients'),
            subtitle: Text(recipe.ingredients),
          ),
          ListTile(
            title: Text('Steps'),
            subtitle: Text(recipe.steps),
          ),
        ],
      ),
    )).toList(),
]

          ],
        ),
      ])
      ),
    );
  }

_fetchRecipe() async {
  setState(() {
    _isLoading = true;
    _recipes=[];
  });
  try {
    final results = await _apiService.getRecipe(_controller.text, selectedServingSize.toDouble());
    setState(() {
      _recipes = results;
      _isLoading = false;
    });
  } catch (e) {
    print(e);  // Print the exception for debugging
    setState(() {
      _recipes  = [
        Recipe(
          header: 'Error',
          ingredients: '',
          steps: 'Failed to generate recipes. Please check the logs for more details.'
        )];
      _isLoading = false;
    });
  }
}
}