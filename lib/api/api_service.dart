import 'dart:convert';
import 'dart:ffi';
import 'package:http/http.dart' as http;

import '../main.dart';

class ApiService {
  final String _apiEndpoint = 'https://api.openai.com/v1/chat/completions';
  final String _apiKey = 'xxxx'; // replace with your OpenAI API Key

  Future<List<Recipe>> getRecipe(String input, double input2) async {
    var response = await http.post(
      Uri.parse(_apiEndpoint),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json'
      },
      body: json.encode({
  "model": "gpt-3.5-turbo",
  "messages": [
    {
      "role": "system",
      "content": "You are an assistant that will be asked for food recipes. Give 3 options and be concise in your response. Return the recipes in a Json format with the following structure {'records':[{'Header': 'some header','Ingredients': 'ingredients', Steps: 'steps'}]. Make one record per recipe. Allways follow the JSend standard for the response. \n"
    },
    {
      "role": "user",
      "content": "Can you give me a recipe with $input. Adjust the recipe for $input2 persons and share the ingredients in the metric system and with Celsius where possible."
    }],
  "temperature": 0.9,
  "max_tokens": 1000,
  "top_p": 1,
  "frequency_penalty": 0,
  "presence_penalty": 0
}),
    );

if (response.statusCode == 200) {
    var data = json.decode(response.body);
    List<Recipe> recipes = [];
    for (var choice in json.decode(data['choices'][0]['message']['content'])['records']) {

      recipes.add(Recipe(
        header: choice['Header'].trim(),
        ingredients: choice['Ingredients'].trim(), 
        steps: choice['Steps'].trim()
      ));
    }
    return recipes;
  } else {
    // Print the response for better understanding of the error
    print("Error: ${response.statusCode} ${response.body}");
    throw Exception('Failed to fetch recipe from OpenAI');
  }

}

  }

