const clickValidationCaseTemplate = '''
FreshSalt 点击验证用例模板

{
  "case_id": "M08_FEATURE",
  "module": "feature_extraction",
  "action": "提取特征",
  "mock_input": {...},
  "expected_output": {...},
  "assertion_rule": "返回完整十维特征"
}

推荐模块：
- model_bundle
- quality_control
- feature_extraction
- prediction
- export_csv
''';
