--------------------------------------------------------
--  DDL for Package Body IGS_EN_GS_ATTRIB_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_GS_ATTRIB_VAL" AS
/* $Header: IGSEN90B.pls 115.1 2002/11/29 00:12:53 nsidana noship $ */

G_PKG_NAME             CONSTANT VARCHAR2(30) := 'IGS_EN_GS_ATTRIB_VAL';
g_prod                 VARCHAR2(3)           := 'IGS';

PROCEDURE Set_Value(
  p_obj_type_id      IN  NUMBER,
  p_obj_id           IN  NUMBER,
  p_attrib_id        IN  NUMBER,
  p_version          IN  NUMBER,
  p_value            IN  VARCHAR2,
  x_return_code      OUT NOCOPY VARCHAR2
)
IS
 l_api_name         CONSTANT VARCHAR2(30)   := 'Set_Value';


 CURSOR c_obj_type IS
   SELECT 'exist'
     FROM igs_en_object_types
    WHERE obj_type_id = p_obj_type_id;


 CURSOR c_attr IS
   SELECT 'exist'
     FROM igs_en_attributes
    WHERE attrib_id = p_attrib_id;


 CURSOR c_rowid IS
   SELECT rowid
     FROM igs_en_attrib_values
    WHERE obj_type_id = p_obj_type_id
      AND obj_id = p_obj_id
      AND attrib_id = p_attrib_id
      AND version = p_version;


 CURSOR c_exists IS
   SELECT 'Y'
     FROM igs_en_attrib_values
     WHERE obj_type_id = p_obj_type_id
      AND obj_id = p_obj_id
      AND attrib_id = p_attrib_id
      AND version = p_version;


 l_value   VARCHAR2(255);
 l_rowid   VARCHAR2(255);
 l_exists  VARCHAR2(1);

BEGIN

  OPEN c_obj_type;
  FETCH c_obj_type INTO l_value;
  IF c_obj_type%NOTFOUND THEN
     x_return_code := 'F01'; --Object type not found
     CLOSE c_obj_type;
     RETURN;
  END IF;
  CLOSE c_obj_type;

  OPEN c_attr;
  FETCH c_attr INTO l_value;
  IF c_attr%NOTFOUND THEN
     x_return_code := 'F02'; --Attribute not found
     CLOSE c_attr;
     RETURN;
  END IF;
  CLOSE c_attr;

  IF p_obj_id IS NULL THEN
     x_return_code := 'F03'; --Invalid object id
     RETURN;
  END IF;

  IF p_version IS NULL THEN
     x_return_code := 'F04';  --Invalid version
     RETURN;
  END IF;

  IF length(p_value)>255 THEN
     x_return_code := 'F05';  --Value too long
     RETURN;
  END IF;

   IF p_value IS NOT NULL THEN

      -- Checking if the record already exists. If yes, then update the record else insert a new record.
      OPEN c_exists;
      FETCH c_exists INTO l_exists;
      CLOSE c_exists;

      IF l_exists = 'Y' THEN
         OPEN c_rowid;
         FETCH c_rowid INTO l_rowid;
	 CLOSE c_rowid;

          -- Updating the current row
   	 IGS_EN_ATTRIB_VALUES_PKG.UPDATE_ROW(
		X_ROWID           =>  l_rowid	    ,
		X_OBJ_TYPE_ID	  =>  p_obj_type_id ,
		X_OBJ_ID	  =>  p_obj_id      ,
		X_ATTRIB_ID       =>  p_attrib_id   ,
		X_VERSION         =>  p_version     ,
		X_VALUE           =>  p_value
		);
           x_return_code := 'S01';
       ELSE
          -- Inserting the record
	  IGS_EN_ATTRIB_VALUES_PKG.INSERT_ROW(
		X_ROWID           =>  l_rowid	    ,
		X_OBJ_TYPE_ID	  =>  p_obj_type_id ,
		X_OBJ_ID	  =>  p_obj_id      ,
		X_ATTRIB_ID       =>  p_attrib_id   ,
		X_VERSION         =>  p_version     ,
		X_VALUE           =>  p_value
		);
	  x_return_code := 'S00';
       END IF;

     END IF;

  EXCEPTION
     WHEN OTHERS THEN
       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       x_return_code := 'F99';
  END Set_Value;


 FUNCTION Get_Value (
   p_obj_type_id      IN  NUMBER,
   p_obj_id           IN  NUMBER,
   p_attrib_id        IN  NUMBER,
   p_version          IN  NUMBER
 ) RETURN VARCHAR2
 IS

  -- Cursor to get the value from the attributes table
  CURSOR c_attr_val IS
    SELECT value
      FROM igs_en_attrib_values
     WHERE obj_type_id = p_obj_type_id
       AND obj_id = p_obj_id
       AND attrib_id = p_attrib_id
       AND version = p_version;

   l_value VARCHAR2(255);

  BEGIN

    OPEN c_attr_val;
    FETCH c_attr_val INTO l_value;
    CLOSE c_attr_val;
    RETURN l_value;

  END Get_Value;

END IGS_EN_GS_ATTRIB_VAL;

/
