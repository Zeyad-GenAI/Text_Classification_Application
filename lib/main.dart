import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF6A1B9A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF6A1B9A),
          secondary: Color(0xFF00BCD4),
        ),
        fontFamily: 'Poppins',
      ),
      home: SentimentAnalysisScreen(),
    );
  }
}

class SentimentAnalysisScreen extends StatefulWidget {
  @override
  _SentimentAnalysisScreenState createState() => _SentimentAnalysisScreenState();
}

class _SentimentAnalysisScreenState extends State<SentimentAnalysisScreen> {
  final TextEditingController _controller = TextEditingController();
  String _result = '';
  double _confidence = 0.0;
  String _processedText = '';
  bool _isLoading = false;

  Future<void> _predictSentiment() async {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter some text to analyze'),
          backgroundColor: Color(0xFF6A1B9A),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://192.168.85.40:5000/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': _controller.text}),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _result = data['result'];
          _confidence = data['confidence'] * 100;
          _processedText = data['processed_text'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _result = 'Error: ${response.statusCode}';
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Server error: ${response.statusCode}'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _result = 'Connection error';
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot connect to server: $e'),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sentiment Analysis',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF6A1B9A),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE1BEE7),
              Color(0xFFF3E5F5),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            Text(
              'Enter text to analyze:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A148C),
              ),
            ),
            SizedBox(height: 10),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: Color(0xFFCE93D8), width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Type or paste text here...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                  ),
                  maxLines: 5,
                ),
              ),
            ),
            SizedBox(height: 25),
            ElevatedButton(
              onPressed: _isLoading ? null : _predictSentiment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF00BCD4),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                shadowColor: Color(0x8000BCD4),
              ),
              child: _isLoading
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text('Analyzing...',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500
                      )
                  ),
                ],
              )
                  : Text(
                  'Analyze',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                  )
              ),
            ),
            SizedBox(height: 30),
            if (_result.isNotEmpty && !_isLoading)
              Card(
                elevation: 6,
                shadowColor: _result == 'Positive'
                    ? Colors.green.withOpacity(0.4)
                    : _result == 'Negative'
                    ? Colors.red.withOpacity(0.4)
                    : Colors.grey.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: _result == 'Positive'
                    ? Color(0xFFE8F5E9)
                    : _result == 'Negative'
                    ? Color(0xFFFFEBEE)
                    : Color(0xFFF5F5F5),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _result == 'Positive'
                                  ? Colors.green[100]
                                  : _result == 'Negative'
                                  ? Colors.red[100]
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Icon(
                              _result == 'Positive'
                                  ? Icons.sentiment_very_satisfied
                                  : _result == 'Negative'
                                  ? Icons.sentiment_very_dissatisfied
                                  : Icons.error_outline,
                              size: 30,
                              color: _result == 'Positive'
                                  ? Colors.green[700]
                                  : _result == 'Negative'
                                  ? Colors.red[700]
                                  : Colors.grey[700],
                            ),
                          ),
                          SizedBox(width: 15),
                          Text(
                            'Result: $_result',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _result == 'Positive'
                                  ? Colors.green[700]
                                  : _result == 'Negative'
                                  ? Colors.red[700]
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                      if (_confidence > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0, left: 8.0),
                          child: Row(
                            children: [
                              Icon(Icons.verified_user,
                                size: 16,
                                color: _result == 'Positive'
                                    ? Colors.green[700]
                                    : _result == 'Negative'
                                    ? Colors.red[700]
                                    : Colors.grey[700],
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Confidence: ${_confidence.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: _result == 'Positive'
                                      ? Colors.green[700]
                                      : _result == 'Negative'
                                      ? Colors.red[700]
                                      : Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_processedText.isNotEmpty)
                        Container(
                          margin: EdgeInsets.only(top: 15),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _result == 'Positive'
                                  ? Colors.green[200]!
                                  : _result == 'Negative'
                                  ? Colors.red[200]!
                                  : Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Processed Text:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                _processedText,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}