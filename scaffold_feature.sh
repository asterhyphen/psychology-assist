#!/bin/bash

# Feature Scaffolding Template
# Copy this script and customize for each feature
# Usage: ./scaffold_feature.sh my_feature

FEATURE_NAME=${1:-example_feature}
BASE_PATH="lib/features/$FEATURE_NAME"

# Create all necessary directories
mkdir -p "$BASE_PATH/presentation/screens"
mkdir -p "$BASE_PATH/presentation/widgets"
mkdir -p "$BASE_PATH/presentation/providers"
mkdir -p "$BASE_PATH/domain/entities"
mkdir -p "$BASE_PATH/domain/repositories"
mkdir -p "$BASE_PATH/data/datasources"
mkdir -p "$BASE_PATH/data/models"
mkdir -p "$BASE_PATH/data/repositories"

echo "✅ Feature '$FEATURE_NAME' directories created"
echo ""
echo "📋 Next steps:"
echo "1. Create domain/entities/{entity}_entity.dart"
echo "2. Create domain/repositories/{entity}_repository.dart (abstract)"
echo "3. Create data/models/{entity}_model.dart"
echo "4. Create data/datasources/local_{entity}_datasource.dart"
echo "5. Create data/repositories/{entity}_repository_impl.dart"
echo "6. Create presentation/providers/{feature}_provider.dart"
echo "7. Create presentation/screens/{feature}_screen.dart"
echo "8. Create {feature_name}_feature.dart (export file)"
echo ""
echo "📚 Reference: lib/features/journaling/ or lib/features/mood_log/"
echo "📖 Guide: ARCHITECTURE_REFACTORING.md"
