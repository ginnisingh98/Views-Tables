--------------------------------------------------------
--  DDL for Package Body XLE_ASSOC_VALIDATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLE_ASSOC_VALIDATIONS_PVT" AS
/* $Header: xleassvb.pls 120.6 2006/03/09 09:16:32 apbalakr ship $ */
-- ==========================================================================
--  PROCEDURE
--    Validate_Mandatory
--
--  DESCRIPTION
--    Check whether the parameter has a value
--
--  ARGUMENTS :
--      IN     :  p_param_name
--                p_param_value
--
--  MODIFICATION HISTORY
--
-- ===========================================================================

PROCEDURE Validate_Mandatory (
  p_param_name 	          IN     VARCHAR2,
  p_param_value	          IN     VARCHAR2)
IS
BEGIN

  IF (p_param_value IS NULL OR p_param_value = FND_API.G_MISS_CHAR) THEN
     FND_MESSAGE.SET_NAME ('XLE', 'XLE_ASSOC_MISSING_PARAM');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
       RAISE;
END Validate_Mandatory;


-- ==========================================================================
--  PROCEDURE
--    Validate_Context
--
--  DESCRIPTION
--    Check whether the context is valid
--
--  ARGUMENTS :
--      IN     :  p_context
--
--  MODIFICATION HISTORY
--
-- ===========================================================================


PROCEDURE Validate_Context (
  p_context	          IN     VARCHAR2)

IS
  CURSOR  Context_Cursor  IS
  SELECT  Association_Type_Id
  FROM 	  XLE_ASSOCIATION_TYPES
  WHERE   CONTEXT = upper(p_context);
  l_association_type_id NUMBER;
BEGIN

  OPEN 	  Context_Cursor;
  FETCH    Context_Cursor INTO l_association_type_id;

  IF (Context_Cursor%NOTFOUND)	THEN
      FND_MESSAGE.SET_NAME  ('XLE', 'XLE_ASSOC_INVALID_PARAM');
      FND_MESSAGE.SET_TOKEN ('PARAM', 'Context');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE Context_Cursor;

EXCEPTION
  WHEN OTHERS THEN
       RAISE;
END Validate_Context;


-- ==========================================================================
--  PROCEDURE
--    Validate_Object
--
--  DESCRIPTION
--    Check whether the Object Type and ID are valid
--
--  ARGUMENTS :
--      IN     :  p_object_type   (Defined in XLE_ASSOC_OBJECT_TYPES)
--    		  p_object_id
--                p_param1_name   (Object Type Parameter Name - Used in Error Message)
--                p_param2_name   (Object Id Parameter Name - Used in Error Message)
--
--      OUT    :  x_OBJECT_type_id
--
--      IN/OUT :
--
--  MODIFICATION HISTORY
--
-- ===========================================================================


PROCEDURE Validate_Object (
  p_object_type           IN     VARCHAR2,
  p_object_id 	          IN     NUMBER  ,
  p_param1_name	          IN     VARCHAR2,
  p_param2_name	          IN     VARCHAR2,
  x_OBJECT_type_id        OUT NOCOPY   NUMBER  )
IS
  l_select_statement VARCHAR2(1000);
  l_OBJECT_type_rec XLE_ASSOC_OBJECT_TYPES%ROWTYPE;
  l_cursor INTEGER;
  l_dummy  INTEGER;

  CURSOR  OBJECT_Type_Cursor	IS
  SELECT  *
  FROM 	  XLE_ASSOC_OBJECT_TYPES
  WHERE   name = upper(p_object_type);

BEGIN

  OPEN 	  OBJECT_Type_Cursor;
  FETCH   OBJECT_Type_Cursor 	INTO	l_OBJECT_type_rec;

  IF (OBJECT_Type_Cursor%NOTFOUND) THEN
      FND_MESSAGE.SET_NAME  ('XLE', 'XLE_ASSOC_INVALID_PARAM');
      FND_MESSAGE.SET_TOKEN ('PARAM', p_param1_name);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE   OBJECT_Type_Cursor;

  l_select_statement := 'SELECT 1 FROM ' || l_OBJECT_type_rec.source_table ||
  ' WHERE ' || l_OBJECT_type_rec.source_column1 || ' =:pk_id';

  IF (l_OBJECT_type_rec.where_clause IS NOT NULL) THEN
     l_select_statement := l_select_statement || ' AND ' || l_OBJECT_type_rec.where_clause;
  END IF;

  l_cursor := DBMS_SQL.OPEN_CURSOR;

  DBMS_SQL.PARSE(l_cursor, l_select_statement, DBMS_SQL.V7);
  DBMS_SQL.BIND_VARIABLE (l_cursor, ':pk_id', p_object_id);

  l_dummy := DBMS_SQL.EXECUTE(l_cursor);

  IF DBMS_SQL.FETCH_ROWS(l_cursor) = 0 THEN
     FND_MESSAGE.SET_NAME  ('XLE', 'XLE_ASSOC_INVALID_PARAM');
     FND_MESSAGE.SET_TOKEN ('PARAM', p_param2_name);
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
  END IF;
  DBMS_SQL.CLOSE_CURSOR (l_cursor);
  x_OBJECT_type_id := l_OBJECT_type_rec.OBJECT_TYPE_ID;

EXCEPTION
   WHEN OTHERS THEN
--        dbms_output.put_line('-- SQLCODE : ' || SQLCODE || ' ' || SQLERRM);
        RAISE;
END Validate_Object;

-- ==========================================================================
--  PROCEDURE
--    Validate_Association_Id
--
--  DESCRIPTION
--    Check whether the association ID is valid
--    Return the Association Type, Subject ID and Object ID
--
--  ARGUMENTS :
--      IN     :  p_association_id
--      OUT    :  p_association_type_id
--                p_subject_id
--                p_object_id
--
--  MODIFICATION HISTORY
--
-- ===========================================================================


PROCEDURE Validate_Association_Id (
    p_association_id      IN     NUMBER,
    p_association_type_id OUT NOCOPY   NUMBER,
    p_subject_id          OUT NOCOPY   NUMBER,
    p_object_id           OUT NOCOPY   NUMBER)
IS

BEGIN
  SELECT association_type_id, subject_id, object_id
  INTO   p_association_type_id, p_subject_id, p_object_id
  FROM   XLE_ASSOCIATIONS
  WHERE  ASSOCIATION_ID = p_association_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
       FND_MESSAGE.SET_NAME  ('XLE', 'XLE_ASSOC_INVALID_PARAM');
       FND_MESSAGE.SET_TOKEN ('PARAM', 'Association Id');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
  WHEN OTHERS THEN
--     dbms_output.put_line('-- SQLCODE : ' || SQLCODE || ' ' || SQLERRM);
       RAISE;
END Validate_Association_Id;


-- ==========================================================================
--  PROCEDURE
--    Default_Association_Type
--
--  DESCRIPTION
--    Check whether the Combination of Subject ID, Object ID, Context is valid
--    Find corresponding Association Type
--
--  ARGUMENTS :
--      IN     :  p_context
--                p_subject_type (ID)
--    		  p_object_type  (ID)
--
--      OUT    :  x_association_type_id
--
--  MODIFICATION HISTORY
--
-- ===========================================================================

PROCEDURE Default_Association_Type (
  p_context               IN     VARCHAR2,
  p_subject_type          IN     NUMBER  ,
  p_object_type           IN     NUMBER  ,
  x_association_type_id   OUT NOCOPY   NUMBER  )

IS

BEGIN
  SELECT ASSOCIATION_TYPE_ID
  INTO   x_association_type_id
  FROM   XLE_ASSOCIATION_TYPES
  WHERE  CONTEXT         =  upper(p_context)
  AND    SUBJECT_TYPE_ID =  p_subject_type
  AND	 OBJECT_TYPE_ID  =  p_object_type;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
       FND_MESSAGE.SET_NAME  ('XLE', 'XLE_NO_ASSOCIATION_TYPE');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
  WHEN OTHERS THEN
       RAISE;

END Default_Association_Type;
-- ==========================================================================
--  PROCEDURE
--    Default_Association_Type
--
--  DESCRIPTION
--    Check whether the Combination of Subject Name, Object Name, Context is valid
--    Find corresponding Association Type
--
--  ARGUMENTS :
--      IN     :  p_context
--                p_subject_type (NAME)
--    		  p_object_type  (NAME)
--
--      OUT    :  x_association_type_id
--
--  MODIFICATION HISTORY
--
-- ===========================================================================

PROCEDURE Default_Association_Type (
  p_context               IN     VARCHAR2,
  p_subject_type          IN     VARCHAR2,
  p_object_type           IN     VARCHAR2,
  x_association_type_id   OUT NOCOPY   NUMBER  )

IS

BEGIN
  SELECT AT.ASSOCIATION_TYPE_ID
  INTO   x_association_type_id
  FROM   XLE_ASSOCIATION_TYPES AT,
         XLE_ASSOC_OBJECT_TYPES ST,
         XLE_ASSOC_OBJECT_TYPES OT
  WHERE  AT.CONTEXT         =  p_context
  AND    AT.SUBJECT_TYPE_ID =  ST.object_type_id
  AND    ST.NAME            =  upper (P_SUBJECT_TYPE)
  AND    AT.OBJECT_TYPE_ID  =  OT.object_type_id
  AND    OT.NAME            =  upper (P_OBJECT_TYPE);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
       FND_MESSAGE.SET_NAME  ('XLE', 'XLE_NO_ASSOCIATION_TYPE');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
  WHEN OTHERS THEN
       RAISE;

END Default_Association_Type;



-- ==========================================================================
--  PROCEDURE
--    Validate_Cardinality
--
--  DESCRIPTION
--    Check  whether the association cardinality is respected
--
--  ARGUMENTS
--      IN    :  p_association_type_id
--               p_subject_id
--               p_object_id
--
--  MODIFICATION HISTORY
--
-- ===========================================================================

PROCEDURE Validate_Cardinality (
  p_association_type_id   IN     NUMBER  ,
  p_subject_type          IN     VARCHAR2,
  p_subject_id            IN     NUMBER  ,
  p_object_type           IN     VARCHAR2,
  p_object_id             IN     NUMBER  )

IS

CURSOR Association_Type_Cursor
IS
SELECT *
FROM   XLE_ASSOCIATION_TYPES
WHERE  ASSOCIATION_TYPE_ID = p_association_type_id;

CURSOR Association_Subject_Cursor
IS
SELECT *
FROM   XLE_ASSOCIATIONS
WHERE  ASSOCIATION_TYPE_ID = p_association_type_id
AND    SUBJECT_ID = p_subject_id
AND    EFFECTIVE_TO IS NULL;

CURSOR Association_Object_Cursor
IS
SELECT *
FROM   XLE_ASSOCIATIONS
WHERE  ASSOCIATION_TYPE_ID = p_association_type_id
AND    OBJECT_ID = p_object_id
AND    EFFECTIVE_TO IS NULL;

l_association_type_rec 	   XLE_ASSOCIATION_TYPES%ROWTYPE;
l_association_subject_rec  XLE_ASSOCIATIONS%ROWTYPE;
l_association_object_rec   XLE_ASSOCIATIONS%ROWTYPE;


BEGIN

  OPEN 	 Association_Type_Cursor;
  FETCH  Association_Type_Cursor 	 INTO	l_association_type_rec;

  IF (Association_Type_Cursor%NOTFOUND)	 THEN
      FND_MESSAGE.SET_NAME  ('XLE', 'XLE_NO_ASSOCIATION_TYPE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE	 Association_Type_Cursor;

  IF  (l_association_type_rec.cardinality in ('MO','OO')) THEN
      OPEN    Association_Subject_Cursor;
      FETCH   Association_Subject_Cursor INTO  l_association_subject_rec;

      IF (Association_Subject_Cursor%FOUND)	THEN
	 IF  (l_association_subject_rec.object_id <> p_object_id) THEN
	     FND_MESSAGE.SET_NAME  ('XLE', 'XLE_ASSOC_INVALID_CARDINALITY');
  	     FND_MESSAGE.SET_TOKEN ('OBJECT1'     , p_subject_id);
        FND_MESSAGE.SET_TOKEN ('TYPE1', p_subject_type);
        FND_MESSAGE.SET_TOKEN ('OBJECT2'     , l_association_subject_rec.object_id);
        FND_MESSAGE.SET_TOKEN ('TYPE2', p_object_type);
        FND_MSG_PUB.ADD;
	     RAISE FND_API.G_EXC_ERROR;
	 END IF;
      END IF;
      CLOSE	 Association_Subject_Cursor;
  END IF;

  IF  (l_association_type_rec.cardinality in ('OM','OO')) THEN
       OPEN    Association_Object_Cursor;
       FETCH 	Association_Object_Cursor INTO	l_association_object_rec;

       IF (Association_Object_Cursor%FOUND)	THEN
         IF (l_association_object_rec.subject_id <> p_subject_id) THEN
      	    FND_MESSAGE.SET_NAME  ('XLE', 'XLE_ASSOC_INVALID_CARDINALITY');
             FND_MESSAGE.SET_TOKEN ('TYPE1',   p_object_type);
      	    FND_MESSAGE.SET_TOKEN ('OBJECT1'     ,   p_object_id);
             FND_MESSAGE.SET_TOKEN ('TYPE2',   p_subject_type);
      	    FND_MESSAGE.SET_TOKEN ('OBJECT2'     ,   l_association_object_rec.subject_id);
             FND_MSG_PUB.ADD;
      	    RAISE FND_API.G_EXC_ERROR;
         END IF;
       END IF;
       CLOSE	 Association_Object_Cursor;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
       RAISE;

END Validate_Cardinality;

-- ==========================================================================
--  PROCEDURE
--    Get_Effective_From_Date
--
--  DESCRIPTION
--    Retrieves the effective from date of an existing association
--
--  ARGUMENTS :
--      IN     :  p_association_id
--
--      OUT    :  p_effective_from
--
--  MODIFICATION HISTORY
--
-- ===========================================================================

PROCEDURE Get_Effective_From_Date (
  p_association_id        IN     NUMBER  ,
  p_effective_from        OUT NOCOPY   DATE    )
IS
BEGIN
  SELECT effective_from
  INTO   p_effective_from
  FROM   XLE_ASSOCIATIONS
  WHERE  ASSOCIATION_ID = p_association_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
       FND_MESSAGE.SET_NAME  ('XLE', 'XLE_ASSOC_INVALID_PARAM');
       FND_MESSAGE.SET_TOKEN ('PARAM', 'Association Id');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
  WHEN OTHERS THEN
       RAISE;
END Get_Effective_From_Date;

-- ==========================================================================
--  FUNCTION
--    Is_Date_Overlap
--
--  DESCRIPTION
--    Returns true if period [s1,e1] overlaps [s2,e2], false otherwise
--
--  ARGUMENTS :
--      IN     :  start_date1  Start date of period 1
--                end_date1    End date of period 1
--    	          start_date2  Start date of period 2
--                end_date2    End date of period 2
--
--  MODIFICATION HISTORY
--
-- ===========================================================================


FUNCTION  Is_date_overlap (
  start_date1 	          IN     DATE    ,
  end_date1	          IN     DATE    ,
  start_date2	          IN     DATE    ,
  end_date2	          IN     DATE    )
RETURN BOOLEAN

IS

BEGIN

  IF (start_date1 between start_date2 and nvl(end_date2, start_date1)) OR
     (start_date2 between start_date1 and nvl(end_date1, start_date2)) THEN
       RETURN true;
  ELSE
       RETURN false;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
       RAISE;
END is_date_overlap;


-- ==========================================================================
--  PROCEDURE
--    Validate_Effective_Dates
--
--  DESCRIPTION
--    Checks that the Association Effective dates are between the Association
--    Type Effective dates.
--
--  ARGUMENTS :
--      IN     :  p_association_type_id
--                p_effective_from
--                p_effective_to
--
--  MODIFICATION HISTORY
--
-- ===========================================================================

PROCEDURE Validate_Effective_Dates (
  p_association_type_id   IN     NUMBER  ,
  p_effective_from	  IN	 DATE    ,
  p_effective_to          IN     DATE := NULL   )

IS

CURSOR Association_Type_Cursor
IS
SELECT *
FROM   XLE_ASSOCIATION_TYPES
WHERE  ASSOCIATION_TYPE_ID = p_association_type_id;

l_association_type_rec   XLE_ASSOCIATION_TYPES%ROWTYPE;

BEGIN

  OPEN 	  Association_Type_Cursor;
  FETCH   Association_Type_Cursor 	INTO	l_association_type_rec;

  IF (Association_Type_Cursor%NOTFOUND)	THEN
      FND_MESSAGE.SET_NAME  ('XLE', 'XLE_NO_ASSOCIATION_TYPE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE   Association_Type_Cursor;

  -- Validates the Association Effective From Date is not posterior to the Effective To Date
  IF  (trunc(p_effective_from) > NVL(p_effective_to, p_effective_from)) THEN
       FND_MESSAGE.SET_NAME  ('XLE', 'XLE_EFF_FROM_TO_DATE_ERR');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Validates the Association Effective Dates are between the Association Types Effective Dates
  IF (trunc(p_effective_from) NOT BETWEEN trunc(l_association_type_rec.effective_from) AND NVL(l_association_type_rec.effective_to, trunc(p_effective_from))) OR
     (p_effective_to IS NOT NULL AND
      p_effective_to NOT BETWEEN trunc(l_association_type_rec.effective_from) AND NVL(l_association_type_rec.effective_to, p_effective_to))           THEN
      FND_MESSAGE.SET_NAME  ('XLE', 'XLE_ASSOC_INVALID_EFF_DATE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END IF;


EXCEPTION
  WHEN OTHERS THEN
       RAISE;
END Validate_Effective_Dates;


-- ==========================================================================
--  PROCEDURE
--    Validate_Overlap_Dates
--
--  DESCRIPTION
--    Check there is no time overlap among associations with same
--    Association Type, Subject_Id, Object_Id
--
--  ARGUMENTS :
--      IN     :  p_association_type_id
--                p_subject_id
--    		  p_object_id
--                p_effective_from
--                p_effective_to
--
--  MODIFICATION HISTORY
--
-- ===========================================================================

PROCEDURE Validate_Overlap_Dates (
  p_association_id        IN     NUMBER := NULL,
  p_association_type_id   IN     NUMBER  ,
  p_subject_id            IN     NUMBER  ,
  p_object_id             IN     NUMBER  ,
  p_effective_from	  IN	 DATE    ,
  p_effective_to          IN     DATE := NULL)

IS

CURSOR Association_Cursor
IS
SELECT *
FROM   XLE_ASSOCIATIONS
WHERE  ASSOCIATION_TYPE_ID = p_association_type_id
AND    SUBJECT_ID = p_subject_id
AND    OBJECT_ID  = p_object_id;


l_association_rec   XLE_ASSOCIATIONS%ROWTYPE;
l_effective_from    DATE;
l_effective_to      DATE;

BEGIN

  IF  (p_effective_from = FND_API.G_MISS_DATE) THEN
      l_effective_from := NULL;
  ELSE
      l_effective_from := p_effective_from;
  END IF;

  IF  (p_effective_to = FND_API.G_MISS_DATE) THEN
      l_effective_to := NULL;
  ELSE
      l_effective_to := p_effective_to;
  END IF;


  FOR l_association_rec IN Association_Cursor
   LOOP
      IF (p_association_id IS NULL AND l_association_rec.effective_to IS NULL) THEN
          FND_MESSAGE.SET_NAME  ('XLE', 'XLE_ASSOC_EXISTS_WARN');
          FND_MSG_PUB.ADD;
     	  RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (p_association_id IS NULL) OR (p_association_id IS NOT NULL AND l_association_rec.association_id <> p_association_id) THEN
          IF  (is_date_overlap (l_effective_from, l_effective_to,
                                l_association_rec.effective_from, l_association_rec.effective_to))       THEN
               FND_MESSAGE.SET_NAME  ('XLE', 'XLE_ASSOC_OVERLAP_DATES');
               FND_MSG_PUB.ADD;
     	         RAISE FND_API.G_EXC_ERROR;
          END IF;
      END IF;
   END LOOP;

EXCEPTION
  WHEN OTHERS THEN
       RAISE;

END Validate_Overlap_Dates;


-- ==========================================================================
--  PROCEDURE
--    Get_Parent_Id
--
--  DESCRIPTION
--    Find the Parent Legal Entity for a given Establishment
--
--  ARGUMENTS :
--      IN     :  p_object_type
--    		  p_object_id
--
--      OUT    :  x_object_parent_id
--
--  MODIFICATION HISTORY
--
-- ===========================================================================


PROCEDURE Get_Parent_Id (
  p_object_type           IN     VARCHAR2,
  p_object_id             IN     NUMBER  ,
  x_object_parent_id      OUT NOCOPY   NUMBER  )
IS

BEGIN
  IF (upper(p_object_type) = 'ESTABLISHMENT') THEN
      SELECT legal_entity_id
      INTO   x_object_parent_id
      FROM   XLE_ETB_PROFILES
      WHERE  establishment_id = p_object_id;
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
       x_object_parent_id := NULL;
  WHEN OTHERS THEN
       RAISE;
END Get_Parent_Id;

-- ==========================================================================
--  PROCEDURE
--    Validate_Parameter_Combination
--
--  DESCRIPTION
--    Validations of the context, subject and  object types and IDs
--    Finds the corresponding Association Type
--
--  ARGUMENTS :
--      IN     :  p_context
--                p_subject_type
--                p_subject_id
--                p_object_type
--    		  p_object_id
--
--      OUT    :  x_association_type_id
--
--  MODIFICATION HISTORY
--
-- ===========================================================================


PROCEDURE Validate_Parameter_Combination (
  p_context               IN     VARCHAR2,
  p_subject_type          IN     VARCHAR2,
  p_subject_id 	   	  IN     NUMBER  ,
  p_object_type           IN     VARCHAR2,
  p_object_id             IN     NUMBER  ,
  x_association_type_id   OUT NOCOPY   NUMBER  )
IS
  l_subject_type_id      NUMBER;
  l_object_type_id       NUMBER;

BEGIN

  -- ****  Validate that all the mandatory input parameters are provided ****

  Validate_Mandatory ('Context'     , p_context);
  Validate_Mandatory ('Subject Type', p_subject_type);
  Validate_Mandatory ('Subject ID'  , p_subject_id);
  Validate_Mandatory ('Object Type' , p_object_type);
  Validate_Mandatory ('Object ID'   , p_object_id);

  -- ****  Validate the context, Subject and  Object Types and IDs ****

  Validate_Context(p_context);
  Validate_Object (p_subject_type, p_subject_id, 'Subject Type','Subject_Id',l_subject_type_id);
  Validate_Object (p_object_type, p_object_id, 'Object Type', 'Object_Id', l_object_type_id);

  -- ****  Defaults the Association Type

  Default_Association_Type (p_context, l_subject_type_id, l_object_type_id, x_association_type_id);

EXCEPTION
  WHEN OTHERS THEN
       RAISE;

END Validate_Parameter_Combination;

-- ==============================================================================
--  PROCEDURE
--    Get_Association_Id
--
--  DESCRIPTION
--    Find an association based on the context, subject and object types and Ids
--
--  ARGUMENTS :
--      IN     :  p_context
--                p_subject_type
--                p_subject_id
--                p_object_type
--    				    p_object_id
--
--      OUT    :  x_association_id
--
--  MODIFICATION HISTORY
--
-- ==============================================================================


PROCEDURE Get_Association_Id   (
  p_subject_id	          IN     NUMBER,
  p_object_id             IN     NUMBER,
  p_association_type_id   IN     NUMBER,
  x_association_id        OUT NOCOPY  NUMBER)
IS

BEGIN

  SELECT association_id
  INTO   x_association_id
  FROM   XLE_ASSOCIATIONS
  WHERE  association_type_id = p_association_type_id
  AND    subject_id          = p_subject_id
  AND    object_id           = p_object_id
  AND    effective_to        IS NULL;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
       FND_MESSAGE.SET_NAME  ('XLE', 'XLE_NO_ASSOCIATION');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
  WHEN OTHERS THEN
       RAISE;
END Get_Association_Id;

-- ==========================================================================
--  PROCEDURE
--    Validate_Intercompany
--
--  DESCRIPTION
--    Validations for Intercompany
--
--  ARGUMENTS :
--      IN     :  p_subject_id
--    		      p_object_id
--
--      OUT    :  x_association_type_id
--                x_subject_parent_id
--
--  MODIFICATION HISTORY
--
-- ====================================================

PROCEDURE Validate_Intercompany   (
  p_subject_id	           IN     NUMBER,
  p_object_id             IN     NUMBER)
IS

le2_name                  VARCHAR(80);
le1_transacting           VARCHAR(1);
le2_transacting           VARCHAR(1);

BEGIN

  SELECT le2.name, le1.transacting_entity_flag, le2.transacting_entity_flag
  INTO   le2_name, le1_transacting, le2_transacting
  FROM   XLE_ENTITY_PROFILES le1,
         XLE_ENTITY_PROFILES le2
  WHERE  le1.legal_entity_id = p_subject_id
  AND    le2.legal_entity_id = p_object_id;

  IF  (le1_transacting <> 'Y' AND le2_transacting <> 'Y') THEN
      FND_MESSAGE.SET_TOKEN('NAME', le2_name);
      FND_MESSAGE.SET_NAME('XLE', 'XLE_REL_IC_ENABLED_WARN');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END IF;


EXCEPTION
  WHEN OTHERS THEN
       RAISE;
END Validate_Intercompany;


-- ==========================================================================
--  PROCEDURE
--    Validate_Create_Association
--
--  DESCRIPTION
--    Validations for Association Creation
--
--  ARGUMENTS :
--      IN     :  p_context
--                p_subject_type
--                p_subject_id
--                p_object_type
--    		  p_object_id
--                p_effective_from
--                p_assoc_information_context
--                p_assoc_information1
--                p_assoc_information2
--                p_assoc_information3
--                p_assoc_information4
--                p_assoc_information5
--                p_assoc_information6
--                p_assoc_information7
--                p_assoc_information8
--                p_assoc_information9
--                p_assoc_information10
--                p_assoc_information11
--                p_assoc_information12
--                p_assoc_information13
--                p_assoc_information14
--                p_assoc_information15
--                p_assoc_information16
--                p_assoc_information17
--                p_assoc_information18
--                p_assoc_information19
--                p_assoc_information20
--
--      OUT    :  x_association_type_id
--                x_subject_parent_id
--
--  MODIFICATION HISTORY
--
-- ===========================================================================


PROCEDURE Validate_Create_Association (
  p_context               IN     VARCHAR2,
  p_subject_type          IN     VARCHAR2,
  p_subject_id 		  IN     NUMBER  ,
  p_object_type           IN     VARCHAR2,
  p_object_id             IN     NUMBER  ,
  p_effective_from        IN     DATE    ,
  p_assoc_information_context IN VARCHAR2,
  p_assoc_information1    IN     VARCHAR2,
  p_assoc_information2    IN     VARCHAR2,
  p_assoc_information3    IN     VARCHAR2,
  p_assoc_information4    IN     VARCHAR2,
  p_assoc_information5    IN     VARCHAR2,
  p_assoc_information6    IN     VARCHAR2,
  p_assoc_information7    IN     VARCHAR2,
  p_assoc_information8    IN     VARCHAR2,
  p_assoc_information9    IN     VARCHAR2,
  p_assoc_information10   IN     VARCHAR2,
  p_assoc_information11   IN     VARCHAR2,
  p_assoc_information12   IN     VARCHAR2,
  p_assoc_information13   IN     VARCHAR2,
  p_assoc_information14   IN     VARCHAR2,
  p_assoc_information15   IN     VARCHAR2,
  p_assoc_information16   IN     VARCHAR2,
  p_assoc_information17   IN     VARCHAR2,
  p_assoc_information18   IN     VARCHAR2,
  p_assoc_information19   IN     VARCHAR2,
  p_assoc_information20   IN     VARCHAR2,
  x_association_type_id   OUT NOCOPY   NUMBER  ,
  x_subject_parent_id     OUT NOCOPY   NUMBER  )
IS
  l_subject_type_id      NUMBER;
  l_object_type_id       NUMBER;
  l_subject_parent_id    NUMBER;
  l_association_type_id  NUMBER;

BEGIN

  -- **** Validates input parameters and finds the corresponding association type
  Validate_Parameter_Combination (p_context, p_subject_type, p_subject_id, p_object_type, p_object_id, x_association_type_id);


  -- ****  Validates effective dates
  Validate_Mandatory ('Effective From Date',p_effective_from);
  Validate_Effective_Dates (x_association_type_id, p_effective_from);


  -- ****  Validates if the Association Type Cardinality is respected
  Validate_Cardinality (x_association_type_id, p_subject_type, p_subject_id, p_object_type, p_object_id);


  -- ****  Validates Dates Overlap
  Validate_Overlap_Dates (NULL, x_association_type_id, p_subject_id, p_object_id, p_effective_from);


  --  ****  Find the Parent Legal Entity if the subject of the Association is an Establishment
  Get_Parent_ID (p_subject_type, p_subject_id, x_subject_parent_id);

EXCEPTION
  WHEN OTHERS THEN
       RAISE;
END Validate_Create_Association;


-- ==========================================================================
--  PROCEDURE
--    Validate_Update_Association
--
--  DESCRIPTION
--    Validations for Association Update
--
--  ARGUMENTS :
--      IN     :  p_context
--                p_subject_type
--                p_subject_id
--                p_object_type
-- 	          p_object_id
--                p_effective_from
--                p_assoc_information_context
--                p_assoc_information1
--                p_assoc_information2
--                p_assoc_information3
--                p_assoc_information4
--                p_assoc_information5
--                p_assoc_information6
--                p_assoc_information7
--                p_assoc_information8
--                p_assoc_information9
--                p_assoc_information10
--                p_assoc_information11
--                p_assoc_information12
--                p_assoc_information13
--                p_assoc_information14
--                p_assoc_information15
--                p_assoc_information16
--                p_assoc_information17
--                p_assoc_information18
--                p_assoc_information19
--                p_assoc_information20
--
--      OUT    :  x_association_type_id
--                x_subject_parent_id
--
--  MODIFICATION HISTORY
--
-- ===========================================================================



PROCEDURE Validate_Update_Association (
  p_association_id        IN OUT NOCOPY NUMBER,
  p_context               IN     VARCHAR2,
  p_subject_type          IN     VARCHAR2,
  p_subject_id 		  IN     NUMBER  ,
  p_object_type           IN     VARCHAR2,
  p_object_id             IN     NUMBER  ,
  p_effective_from        IN     DATE    ,
  p_effective_to          IN     DATE    ,
  p_assoc_information_context IN VARCHAR2,
  p_assoc_information1    IN     VARCHAR2,
  p_assoc_information2    IN     VARCHAR2,
  p_assoc_information3    IN     VARCHAR2,
  p_assoc_information4    IN     VARCHAR2,
  p_assoc_information5    IN     VARCHAR2,
  p_assoc_information6    IN     VARCHAR2,
  p_assoc_information7    IN     VARCHAR2,
  p_assoc_information8    IN     VARCHAR2,
  p_assoc_information9    IN     VARCHAR2,
  p_assoc_information10   IN     VARCHAR2,
  p_assoc_information11   IN     VARCHAR2,
  p_assoc_information12   IN     VARCHAR2,
  p_assoc_information13   IN     VARCHAR2,
  p_assoc_information14   IN     VARCHAR2,
  p_assoc_information15   IN     VARCHAR2,
  p_assoc_information16   IN     VARCHAR2,
  p_assoc_information17   IN     VARCHAR2,
  p_assoc_information18   IN     VARCHAR2,
  p_assoc_information19   IN     VARCHAR2,
  p_assoc_information20   IN     VARCHAR2)

IS
  l_association_type_id  NUMBER := NULL;
  l_effective_from   DATE   := NULL;
  l_effective_to     DATE   := NULL;
  l_object_id        NUMBER := NULL;
  l_subject_id       NUMBER := NULL;

BEGIN

  IF (p_association_id IS NULL) OR (p_association_id = FND_API.G_MISS_NUM) THEN
      Validate_Parameter_Combination (
         p_context,
         p_subject_type,
         p_subject_id,
         p_object_type,
         p_object_id,
         l_association_type_id);
      Get_Association_Id (p_subject_id, p_object_id, l_association_type_id, p_association_id);
      l_subject_id := p_subject_id;
      l_object_id  := p_object_id;
  ELSE
      Validate_Association_Id (p_association_id, l_association_type_id, l_subject_id, l_object_id);
  END IF;

  --  ****   Check Effective From Date is not set to NULL

  IF (p_effective_from = FND_API.G_MISS_DATE) THEN
      FND_MESSAGE.SET_NAME  ('XLE', 'XLE_ASSOC_MISSING_PARAM');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  --  ****  Check that at least one new Effective Date (From or To) is provided or Developer Flexfields

  IF (p_effective_from IS NULL) AND (p_effective_to = FND_API.G_MISS_DATE OR p_effective_to IS NULL) AND
     (p_assoc_information_context IS NULL)  THEN
      FND_MESSAGE.SET_NAME  ('XLE', 'XLE_ASSOC_MISSING_PARAM');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF  (p_effective_to = FND_API.G_MISS_DATE) THEN
      l_effective_to := NULL;
  ELSE
      l_effective_to := p_effective_to;
  END IF;

  IF  (p_effective_from IS NOT NULL) THEN
      l_effective_from := p_effective_from;
  ELSE
      Get_Effective_From_Date (p_association_id, l_effective_from);
  END IF;

  -- ****  Validates effective dates
  Validate_Effective_Dates (l_association_type_id, l_effective_from, l_effective_to);


  -- ****  Validates Dates Overlap
  Validate_Overlap_Dates (p_association_id, l_association_type_id, l_subject_id, l_object_id, l_effective_from, l_effective_to);



EXCEPTION
  WHEN OTHERS THEN
       RAISE;
END Validate_Update_Association;


END XLE_ASSOC_VALIDATIONS_PVT;


/
