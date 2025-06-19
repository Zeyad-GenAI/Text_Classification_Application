import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;

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

class _SentimentAnalysisScreenState extends State<SentimentAnalysisScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  String _result = '';
  double _confidence = 0.0;
  String _processedText = '';
  bool _isLoading = false;

  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late AnimationController _rotationController;
  late AnimationController _bounceController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize Animation Controllers
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _rotationController = AnimationController(
      duration: Duration(milliseconds: 3000),
      vsync: this,
    );
    _bounceController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    // Initialize Animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.bounceOut));
    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );
    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.bounceOut),
    );

    // Start continuous animations
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();

    // Start initial animations
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _progressController.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    _rotationController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  Future<void> _predictSentiment() async {
    if (_controller.text.trim().isEmpty) {
      _showCustomSnackBar('Please enter some text to analyze', Colors.orange);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _progressController.reset();
    _progressController.forward();
    _bounceController.reset();
    _bounceController.forward();

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

        _fadeController.reset();
        _scaleController.reset();
        _fadeController.forward();
        _scaleController.forward();

      } else {
        setState(() {
          _result = 'Error: ${response.statusCode}';
          _isLoading = false;
        });
        _showCustomSnackBar('Server error: ${response.statusCode}', Colors.red);
      }
    } catch (e) {
      setState(() {
        _result = 'Connection error';
        _isLoading = false;
      });
      _showCustomSnackBar('Cannot connect to server', Colors.red);
    }
  }

  void _showCustomSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 10),
              Expanded(child: Text(message, style: TextStyle(fontSize: 14))),
            ],
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF6A1B9A),
                Color(0xFF8E24AA),
                Color(0xFFAB47BC),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: GradientRotation(_rotationAnimation.value * 0.1),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingParticles() {
    return Stack(
      children: List.generate(5, (index) {
        return AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Positioned(
              top: 50 + (index * 80.0),
              left: 20 + (index * 60.0),
              child: Transform.scale(
                scale: _pulseAnimation.value * (0.3 + index * 0.1),
                child: Container(
                  width: 8 + (index * 4.0),
                  height: 8 + (index * 4.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1 + index * 0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildHeader() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF6A1B9A).withOpacity(0.4),
                          blurRadius: 25,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: AnimatedBuilder(
                      animation: _rotationController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationAnimation.value * 0.1,
                          child: Icon(
                            Icons.psychology_outlined,
                            size: 45,
                            color: Color(0xFF6A1B9A),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            AnimatedDefaultTextStyle(
              duration: Duration(milliseconds: 800),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(0, 3),
                    blurRadius: 6,
                    color: Colors.black.withOpacity(0.4),
                  ),
                ],
              ),
              child: Text('Sentiment Analysis'),
            ),
            SizedBox(height: 12),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'Discover hidden emotions in your text',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 600),
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedDefaultTextStyle(
            duration: Duration(milliseconds: 500),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A148C),
            ),
            child: Text('Enter text to analyze:'),
          ),
          SizedBox(height: 12),
          AnimatedContainer(
            duration: Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Color(0xFFE1BEE7), width: 2),
              ),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 600),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [Colors.white, Color(0xFFFAFAFA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Type or paste your text here...',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          prefixIcon: Transform.scale(
                            scale: _pulseAnimation.value * 0.9,
                            child: Icon(
                              Icons.edit_outlined,
                              color: Color(0xFF6A1B9A),
                            ),
                          ),
                        ),
                        maxLines: 6,
                        style: TextStyle(fontSize: 16, height: 1.5),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: AnimatedBuilder(
        animation: _bounceController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (_bounceAnimation.value * 0.1),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  colors: _isLoading
                      ? [Colors.grey[400]!, Colors.grey[500]!]
                      : [Color(0xFF00BCD4), Color(0xFF0097A7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF00BCD4).withOpacity(_isLoading ? 0.2 : 0.4),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _predictSentiment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: _isLoading
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _rotationController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationAnimation.value,
                          child: SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 16),
                    AnimatedDefaultTextStyle(
                      duration: Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      child: Text('Analyzing...'),
                    ),
                  ],
                )
                    : AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Transform.scale(
                          scale: _pulseAnimation.value * 0.9,
                          child: Icon(
                            Icons.analytics_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Analyze Text',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultCard() {
    if (_result.isEmpty || _isLoading) return SizedBox.shrink();

    Color resultColor = _result == 'Positive'
        ? Colors.green
        : _result == 'Negative'
        ? Colors.red
        : Colors.orange;

    IconData resultIcon = _result == 'Positive'
        ? Icons.sentiment_very_satisfied
        : _result == 'Negative'
        ? Icons.sentiment_very_dissatisfied
        : Icons.sentiment_neutral;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: resultColor.withOpacity(0.3),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            color: resultColor.withOpacity(0.05),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 800),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: resultColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Result Header with Animation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: resultColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: resultColor.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: AnimatedBuilder(
                                  animation: _rotationController,
                                  builder: (context, child) {
                                    return Transform.rotate(
                                      angle: _rotationAnimation.value * 0.05,
                                      child: Icon(
                                        resultIcon,
                                        size: 40,
                                        color: resultColor,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedDefaultTextStyle(
                              duration: Duration(milliseconds: 500),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600]!,
                                fontWeight: FontWeight.w500,
                              ),
                              child: Text('Result'),
                            ),
                            AnimatedDefaultTextStyle(
                              duration: Duration(milliseconds: 600),
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: resultColor,
                              ),
                              child: Text(_result),
                            ),
                          ],
                        ),
                      ],
                    ),

                    if (_confidence > 0) ...[
                      SizedBox(height: 24),
                      // Animated Confidence Section
                      AnimatedContainer(
                        duration: Duration(milliseconds: 800),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: resultColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    AnimatedBuilder(
                                      animation: _pulseController,
                                      builder: (context, child) {
                                        return Transform.scale(
                                          scale: _pulseAnimation.value * 0.9,
                                          child: Icon(
                                            Icons.verified_user,
                                            size: 20,
                                            color: resultColor,
                                          ),
                                        );
                                      },
                                    ),
                                    SizedBox(width: 8),
                                    AnimatedDefaultTextStyle(
                                      duration: Duration(milliseconds: 500),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[700]!,
                                      ),
                                      child: Text('Confidence Level'),
                                    ),
                                  ],
                                ),
                                AnimatedDefaultTextStyle(
                                  duration: Duration(milliseconds: 600),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: resultColor,
                                  ),
                                  child: Text('${_confidence.toStringAsFixed(1)}%'),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            // Animated Progress Bar
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: AnimatedBuilder(
                                animation: _progressController,
                                builder: (context, child) {
                                  return FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: (_confidence / 100) * _progressAnimation.value,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            resultColor.withOpacity(0.7),
                                            resultColor,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (_processedText.isNotEmpty) ...[
                      SizedBox(height: 20),
                      // Animated Processed Text Section
                      AnimatedContainer(
                        duration: Duration(milliseconds: 1000),
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: resultColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: _pulseAnimation.value * 0.9,
                                      child: Icon(
                                        Icons.text_fields,
                                        size: 18,
                                        color: Colors.grey[600],
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(width: 8),
                                AnimatedDefaultTextStyle(
                                  duration: Duration(milliseconds: 500),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700]!,
                                  ),
                                  child: Text('Processed Text:'),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: Text(
                                _processedText,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey[800],
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
          _buildAnimatedBackground(),

          // Floating Particles
          _buildFloatingParticles(),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 800),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: Offset(0, -8),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 30),
                          _buildInputSection(),
                          _buildAnalyzeButton(),
                          _buildResultCard(),
                          SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}