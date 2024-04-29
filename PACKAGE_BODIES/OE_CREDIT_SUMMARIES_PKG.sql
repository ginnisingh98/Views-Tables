--------------------------------------------------------
--  DDL for Package Body OE_CREDIT_SUMMARIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CREDIT_SUMMARIES_PKG" AS
-- $Header: OEXCRSMB.pls 115.3 2003/10/20 06:51:36 appldev ship $
--------------------
-- TYPE DECLARATIONS
--------------------

------------
-- CONSTANTS
------------
  G_PKG_NAME CONSTANT VARCHAR2(30)    :='OE_CREDIT_SUMMARIES_PKG';

-------------------
-- PUBLIC VARIABLES
-------------------

---------------------------
-- PROCEDURES AND FUNCTIONS
---------------------------

------------------------------------------------------------
--- FUNCTION get_party_id
---------------------------------------------------------------
FUNCTION get_party_id (p_cust_account_id IN NUMBER )
RETURN NUMBER
IS

l_id number;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
 l_id := NULL;
  BEGIN
    SELECT
        party_id
    INTO
      l_id
    FROM
       HZ_CUST_ACCOUNTS
    WHERE
       cust_account_id = p_cust_account_id ;

    EXCEPTION
    WHEN NO_DATA_FOUND
    THEN

       l_id := NULL ;
       oe_debug_pub.add('OEXCRSMB Exception - No data found in get_party_id ');

   END;


   oe_debug_pub.add(' Return l_id => '|| l_id );

   RETURN (l_id);

EXCEPTION
  WHEN OTHERS THEN
    IF OE_MSG_PUB.Check_msg_level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
       OE_MSG_PUB.Add_exc_msg(G_PKG_NAME,'get_party_id');
    END IF;
    RAISE;

END get_party_id ;
--=====================================================================
--NAME:         Insert_Row
--TYPE:         PRIVATE
--COMMENTS:     Insert a row into the OE_CREDIT_SUMMARIES table.
--Parameters:
--IN
--OUT
--=====================================================================

PROCEDURE Insert_Row
  ( p_cust_account_id            IN  NUMBER
  , p_org_id                     IN  NUMBER
  , p_site_use_id                IN  NUMBER
  , p_currency_code              IN  VARCHAR2
  , p_balance_type               IN  NUMBER
  , p_balance                    IN  NUMBER
  , p_creation_date              IN  DATE
  , p_created_by                 IN  NUMBER
  , p_last_update_date           IN  DATE
  , p_last_updated_by            IN  NUMBER
  , p_last_update_login          IN  NUMBER
  , p_program_application_id     IN  NUMBER
  , p_program_id                 IN  NUMBER
  , p_program_update_date        IN  DATE
  , p_request_id                 IN  NUMBER
  , p_exposure_source_code       IN  VARCHAR2
  )
IS
l_party_id NUMBER ;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  OE_DEBUG_PUB.ADD('OEXCRSMB - IN Insert row ');

  l_party_id := NULL ;
  l_party_id :=
    get_party_id(p_cust_account_id => p_cust_account_id );

  INSERT INTO oe_credit_summaries (
      cust_account_id
    , org_id
    , site_use_id
    , currency_code
    , balance_type
    , balance
    , creation_date
    , created_by
    , last_update_date
    , last_updated_by
    , last_update_login
    , program_application_id
    , program_id
    , program_update_date
    , request_id
    , exposure_source_code
    , party_id
    , bucket
    , bucket_duration
   )
   VALUES (
      p_cust_account_id
    , p_org_id
    , p_site_use_id
    , p_currency_code
    , p_balance_type
    , p_balance
    , p_creation_date
    , p_created_by
    , p_last_update_date
    , p_last_updated_by
    , p_last_update_login
    , p_program_application_id
    , p_program_id
    , p_program_update_date
    , p_request_id
    , p_exposure_source_code
    , l_party_id
    , -1
    , OE_CREDIT_EXPOSURE_PVT.G_MAX_BUCKET_LENGTH
   );

OE_DEBUG_PUB.ADD('OEXCRSMB - OUT NOCOPY Insert row ');

EXCEPTION
  WHEN OTHERS THEN
    IF OE_MSG_PUB.Check_msg_level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
       OE_MSG_PUB.Add_exc_msg(G_PKG_NAME,'Insert_row');
    END IF;
    RAISE;
END Insert_row;

--=====================================================================
--NAME:         Update_Row
--TYPE:         PRIVATE
--COMMENTS:     Update a row in the OE_CREDIT_SUMMARIES table.
--Parameters:
--IN
--OUT
--=====================================================================

PROCEDURE Update_Row
  ( p_row_id                     IN  VARCHAR2
  , p_balance                    IN  NUMBER
  , p_last_update_date           IN  DATE
  , p_last_updated_by            IN  NUMBER
  , p_last_update_login          IN  NUMBER
  , p_program_application_id     IN  NUMBER
  , p_program_id                 IN  NUMBER
  , p_program_update_date        IN  DATE
  , p_request_id                 IN  NUMBER
  )
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   OE_DEBUG_PUB.ADD('OEXCRSMB - IN Update row');
  UPDATE oe_credit_summaries
  SET
      balance                  = p_balance
    , last_update_date         = p_last_update_date
    , last_updated_by          = p_last_updated_by
    , last_update_login        = p_last_update_login
    , program_application_id   = p_program_application_id
    , program_id               = p_program_id
    , program_update_date      = p_program_update_date
    , request_id               = p_request_id
  WHERE ROWID = CHARTOROWID(p_row_id);

OE_DEBUG_PUB.ADD('OEXCRSMB - OUT NOCOPY Update row');


EXCEPTION
  WHEN OTHERS THEN
    IF OE_MSG_PUB.Check_msg_level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
       OE_MSG_PUB.Add_exc_msg(G_PKG_NAME,'Update_row');
    END IF;
    RAISE;
END Update_Row;

--=====================================================================
--NAME:         Delete_Row
--TYPE:         PRIVATE
--COMMENTS:     Delete a row in the OE_CREDIT_SUMMARIES table.
--Parameters:
--IN
--OUT
--=====================================================================

PROCEDURE Delete_Row
  ( p_row_id                     IN  VARCHAR2
  )
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  DELETE FROM oe_credit_summaries
  WHERE ROWID = CHARTOROWID(p_row_id);
EXCEPTION
  WHEN OTHERS THEN
    IF OE_MSG_PUB.Check_msg_level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
       OE_MSG_PUB.Add_exc_msg(G_PKG_NAME,'Update_row');
    END IF;
    RAISE;
END Delete_Row;

END OE_CREDIT_SUMMARIES_PKG;

/
