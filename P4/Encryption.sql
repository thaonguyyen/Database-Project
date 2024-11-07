--encrypt password column in User
--create master key
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'TravelPassword123';

--create certificate
CREATE CERTIFICATE PasswordCert
WITH SUBJECT = 'Certificate for Password Column Encryption';

--create symmetric key
CREATE SYMMETRIC KEY PasswordKey
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE PasswordCert;

--add column for encrypted data
ALTER TABLE [User]
ADD encrypted_password VARBINARY(50);