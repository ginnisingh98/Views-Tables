--------------------------------------------------------
--  DDL for Package Body GR_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_VALIDATE" AS
/* $Header: GRVALIDB.pls 120.0 2005/06/24 11:08:22 mgrosser noship $ */

---------------------------------------------------------------------
-- Function: Validate_item
--
-- Description:
--   Validate the item if its a valid item or not
--
-- History:
--  29-APR-2005      Preetam Bamb         Created.
--  M. Grosser 23-May-2005  Modified code for Inventory Convergence.
--     Added IN parameter p_organization_id and OUT parameter
--     x_inventory_item_id and modified code to check values against
--     the appropriate tables.
---------------------------------------------------------------------
FUNCTION validate_item
(   p_organization_id         IN          NUMBER,
    p_item                    IN          VARCHAR2,
    x_inventory_item_id       OUT NOCOPY  NUMBER
) RETURN BOOLEAN IS

-- Cursor used to validate item
   CURSOR c_val_item IS
     SELECT inventory_item_id
       FROM mtl_system_items_kfv
      WHERE concatenated_segments = p_item and
            organization_id = p_organization_id;


-- Local Variables
   l_inventory_item_id	 MTL_SYSTEM_ITEMS_B.inventory_item_id%TYPE;

BEGIN

   OPEN c_val_item;
   FETCH c_val_item into l_inventory_item_id;
   IF (c_val_item%NOTFOUND) THEN
      CLOSE c_val_item;
      RAISE NO_DATA_FOUND;
   ELSE
      CLOSE c_val_item;
      x_inventory_item_id := l_inventory_item_id;
      RETURN G_TRUE;
   END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.SET_NAME('GR', 'GR_INVALID_ITEM');
         FND_MESSAGE.SET_TOKEN('ITEM', p_item);
         FND_MSG_PUB.Add;
      END IF;
      RETURN G_FALSE;

   WHEN OTHERS THEN
      RETURN G_FALSE;

END validate_item;

---------------------------------------------------------------------
-- Function: validate cas_number
--
-- Description:
--   Validate the cas number is valid for the item or not.
--
-- History:
--  29-APR-2005      Preetam Bamb         Created.
--  M. Grosser 23-May-2005  Modified code for Inventory Convergence.
--     Added IN parameter p_organization_id and OUT parameter
--     x_inventory_item_id and modified code to check values against
--     the appropriate tables.
---------------------------------------------------------------------
FUNCTION validate_cas_number
(       p_organization_id        IN          NUMBER,
        p_cas_number             IN          VARCHAR2,
        x_item                   OUT NOCOPY  VARCHAR2,
        x_inventory_item_id      OUT NOCOPY  NUMBER
) RETURN BOOLEAN IS


-- Cursor used to validate cas_number
   CURSOR c_val_cas_number IS
     SELECT inventory_item_id, concatenated_segments
        FROM  mtl_system_items_kfv
        WHERE  cas_number = p_cas_number and
               organization_id = p_organization_id;

-- Local Variables
   l_inventory_item_id	 MTL_SYSTEM_ITEMS_B.inventory_item_id%TYPE;
   l_item                VARCHAR2(240);

BEGIN
   OPEN c_val_cas_number;
   FETCH c_val_cas_number into l_inventory_item_id, l_item;
   IF (c_val_cas_number%NOTFOUND) THEN
      CLOSE c_val_cas_number;
      RAISE NO_DATA_FOUND;
   ELSE
      CLOSE c_val_cas_number;
      x_inventory_item_id := l_inventory_item_id;
      x_item := l_item;
      RETURN G_TRUE;
   END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.SET_NAME('GR', 'GR_INVALID_CAS_NUMBER');
         FND_MESSAGE.SET_TOKEN('CAS_NUMBER', p_cas_number);
         FND_MSG_PUB.Add;
      END IF;
      RETURN G_FALSE;

   WHEN OTHERS THEN
      RETURN G_FALSE;

END validate_cas_number;

---------------------------------------------------------------------
-- Function: validate_document_code
--
-- Description:
--   Validate the document code.
--
-- History:
--  29-APR-2005      Preetam Bamb         Created.
--
---------------------------------------------------------------------
FUNCTION validate_document_code (p_document_code IN VARCHAR2) RETURN BOOLEAN  IS

--Cursor used to validate document code
CURSOR c_val_document_code IS
SELECT 1
FROM   fnd_lookup_values
WHERE LANGUAGE = USERENV('LANG')
  AND view_application_id BETWEEN 550 AND 559
  AND security_group_id = 0
  AND lookup_code = p_document_code
  AND    lookup_type = 'GR_DOCUMENT_CODE';

--Local Variables
l_temp	      NUMBER;

BEGIN

   OPEN c_val_document_code;
   FETCH c_val_document_code into l_temp;
   IF (c_val_document_code%NOTFOUND) THEN
      CLOSE c_val_document_code;
      RAISE NO_DATA_FOUND;
   ELSE
      CLOSE c_val_document_code;
      RETURN G_TRUE;
   END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.SET_NAME('GR', 'GR_INVALID_DOCUMENT_CODE');
         FND_MESSAGE.SET_TOKEN('CODE', p_document_code);
         FND_MSG_PUB.Add;
      END IF;
      RETURN G_FALSE;

   WHEN OTHERS THEN
      RETURN G_FALSE;

END validate_document_code;


---------------------------------------------------------------------
-- Function: validate_disclosure_code
--
-- Description:
--   Validate the disclosure code.
--
-- History:
--  29-APR-2005      Preetam Bamb         Created.
--
---------------------------------------------------------------------
FUNCTION validate_disclosure_code(p_disclosure_code IN VARCHAR2) RETURN BOOLEAN  IS

--Cursor used to validate document code
CURSOR c_val_disclosure_code IS
SELECT 1
FROM   gr_disclosures
WHERE  disclosure_code = p_disclosure_code;

--Local Variables
l_temp	      NUMBER;

BEGIN

   OPEN c_val_disclosure_code;
   FETCH c_val_disclosure_code into l_temp;
   IF (c_val_disclosure_code%NOTFOUND) THEN
      CLOSE c_val_disclosure_code;
      RAISE NO_DATA_FOUND;
   ELSE
      CLOSE c_val_disclosure_code;
      RETURN G_TRUE;
   END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.SET_NAME('GR', 'GR_INVALID_DISCLOSURE_CODE');
         FND_MESSAGE.SET_TOKEN('DISCLOSURE_CODE', p_disclosure_code);
         FND_MSG_PUB.Add;
      END IF;
   RETURN G_FALSE;

   WHEN OTHERS THEN
      RETURN G_FALSE;

END validate_disclosure_code;


---------------------------------------------------------------------
-- Function: validate_dispatch_method_code
--
-- Description:
--   Validate the dispatch method code.
--
-- History:
--  29-APR-2005      Preetam Bamb         Created.
--
---------------------------------------------------------------------
FUNCTION validate_dispatch_method_code(p_dispatch_method_code IN VARCHAR2) RETURN BOOLEAN  IS

--Cursor used to validate document code
CURSOR c_val_dispatch_method_code IS
SELECT 1
FROM   fnd_lookup_values
WHERE LANGUAGE = USERENV('LANG')
  AND view_application_id BETWEEN 550 AND 559
  AND security_group_id = 0
  AND lookup_code = p_dispatch_method_code
  AND lookup_type = 'GR_DISPATCH_METHOD_CODE';

--Local Variables
l_temp	      NUMBER;

BEGIN

   OPEN c_val_dispatch_method_code;
   FETCH c_val_dispatch_method_code into l_temp;
   IF (c_val_dispatch_method_code%NOTFOUND) THEN
      CLOSE c_val_dispatch_method_code;
      RAISE NO_DATA_FOUND;
   ELSE
      CLOSE c_val_dispatch_method_code;
      RETURN G_TRUE;
   END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.SET_NAME('GR', 'GR_INVALID_DISPATCH_METHOD');
         FND_MESSAGE.SET_TOKEN('DISPATCH_METHOD_CODE', p_dispatch_method_code);
         FND_MSG_PUB.Add;
      END IF;

      RETURN G_FALSE;

   WHEN OTHERS THEN
      RETURN G_FALSE;

END validate_dispatch_method_code;

---------------------------------------------------------------------
-- Function: validate_recipient_id
--
-- Description:
--   Validate the recipient_id.
--
-- History:
--  29-APR-2005      Preetam Bamb         Created.
--
---------------------------------------------------------------------
FUNCTION validate_recipient_id(p_recipient_id IN NUMBER) RETURN BOOLEAN  IS

--Cursor used to validate recipient id
CURSOR c_val_recipient_id IS
SELECT 1
FROM   hz_parties
WHERE  party_id = p_recipient_id;

--Local Variables
l_temp	      NUMBER;

BEGIN

   OPEN c_val_recipient_id;
   FETCH c_val_recipient_id into l_temp;
   IF (c_val_recipient_id%NOTFOUND) THEN
      CLOSE c_val_recipient_id;
      RAISE NO_DATA_FOUND;
   ELSE
      CLOSE c_val_recipient_id;
      RETURN G_TRUE;
   END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.SET_NAME('GR', 'GR_INVALID_RECIPIENT');
         FND_MESSAGE.SET_TOKEN('RECIPIENT_ID', p_recipient_id);
         FND_MSG_PUB.Add;
      END IF;

      RETURN G_FALSE;

   WHEN OTHERS THEN
      RETURN G_FALSE;

END validate_recipient_id;

---------------------------------------------------------------------
-- Function: validate_recipient_site_id
--
-- Description:
--   Validate the recipient_site_id.
--
-- History:
--  29-APR-2005      Preetam Bamb         Created.
--
---------------------------------------------------------------------
FUNCTION validate_recipient_site_id(p_recipient_id IN NUMBER, p_recipient_site_id IN NUMBER) RETURN BOOLEAN  IS

--Cursor used to validate recipient site id
CURSOR c_val_recipient_site_id IS
SELECT 1
FROM   hz_party_sites
WHERE  party_id = p_recipient_id and
party_site_id   = p_recipient_site_id;

--Local Variables
l_temp	      NUMBER;

BEGIN

   OPEN c_val_recipient_site_id;
   FETCH c_val_recipient_site_id into l_temp;
   IF (c_val_recipient_site_id%NOTFOUND) THEN
      CLOSE c_val_recipient_site_id;
      RAISE NO_DATA_FOUND;
   ELSE
      CLOSE c_val_recipient_site_id;
      RETURN G_TRUE;
   END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.SET_NAME('GR', 'GR_INVALID_RECIPIENT_SITE');
         FND_MESSAGE.SET_TOKEN('RECIPIENT_SITE_ID', p_recipient_site_id);
         FND_MSG_PUB.Add;
      END IF;
      RETURN G_FALSE;

   WHEN OTHERS THEN
      RETURN G_FALSE;

END validate_recipient_site_id;


END GR_VALIDATE;

/
