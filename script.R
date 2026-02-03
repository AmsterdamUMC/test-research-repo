# Security Check Test File
#
# This file contains FAKE data to test security detection.
# Attempting to commit/push this file should trigger all security checks.
#
# Usage:
#   git add test-security-detections.txt
#   git commit -m "test"      # Should be blocked by pre-commit
#   git push                  # Should be blocked by pre-push and GitHub Action
#
# After testing, remove with:
#   git reset HEAD test-security-detections.txt
#   rm test-security-detections.txt
'small change'

================================================================================
BSN - Burgerservicenummer (valid 11-proof)
================================================================================
Patient BSN: 111222333
Another BSN: 123456782
Test BSN: 010464715

================================================================================
Patient IDs (7-digit)
================================================================================
MRN: 1234567
Patient ID: 7654321
Record: 9876543

================================================================================
Dutch Full Names (firstname + capitalized word)
================================================================================
Jan Jansen
Pieter Bakker
Maria Visser
Willem de Groot

================================================================================
Dutch Full Names (capitalized word + surname)
================================================================================
Anna Smit
Thomas Mulder
Sophie Bos

================================================================================
Dutch Addresses (known street + number)
================================================================================
Kalverstraat 10
Damrak 45
Rokin 78

================================================================================
Dutch Addresses (street suffix pattern + number)
================================================================================
Meibergdreef 9
Amstelveenseweg 123
Hoofdstraat 45
Dorpsplein 1
Herengracht 500

================================================================================
End of test file
================================================================================
