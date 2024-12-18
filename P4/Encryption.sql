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
ALTER COLUMN encrypted_password VARBINARY(120);

--populate encrypted_password using encryption
OPEN SYMMETRIC KEY PasswordKey
DECRYPTION BY CERTIFICATE PasswordCert;
UPDATE [User]
SET encrypted_password = EncryptByKey(Key_GUID('PasswordKey'), [password]);
CLOSE SYMMETRIC KEY PasswordKey;