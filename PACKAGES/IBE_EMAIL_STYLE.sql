--------------------------------------------------------
--  DDL for Package IBE_EMAIL_STYLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_EMAIL_STYLE" AUTHID CURRENT_USER AS
/* $Header: IBEVESS.pls 120.1.12010000.3 2016/10/13 11:55:02 kdosapat noship $ */

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'IBE_EMAIL_STYLE';

-- Start of comments
--    API name   : Email_Style
--    Type       : Public.
--    Function   : Retrieves email_format for the input parameters as per the below processing steps :
--                 1. Both fnd_user_id and email_address passed :
--                   a. Find matching active record with primary flag=Y.
--                   b. If no records in step a., find matching active latest record.
--                   c. If no records in step b., Return default IBE profile value.
--
--                 2. Only email_address : Return default IBE profile value.
--
--                 3. Only fnd_user_id   :
--                   a. Find active record with primary flag=Y.
--                   b. If no records in step a, Return default IBE profile value.
--
--                 4. Both fnd_user_id and email_address null : Return default IBE profile value
--
--    Pre-reqs   : None.
--    Parameters :
--    IN         : FND_USER_ID            IN  VARCHAR2 Optional
--                 FND_USER_ID_MAIL_ADDR  IN  VARCHAR2 Optional (email_address)
--
--    OUT        : X_EMAIL_STYLE_CODE     OUT VARCHAR2 Required (email_format)
--
--
--    Version    : Current version	1.0
--
--                 previous version	None
--
--                 Initial version 	1.0
--
--    Notes      : Note text
--
-- End of comments
    procedure Email_Style
  (
  FND_USER_ID IN  VARCHAR2,
  FND_USER_ID_MAIL_ADDR IN  VARCHAR2,
  X_EMAIL_STYLE_CODE OUT NOCOPY VARCHAR2
);


END IBE_EMAIL_STYLE;

/
