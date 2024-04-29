--------------------------------------------------------
--  DDL for Package Body CS_KB_ELEMENTS_AUDIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_KB_ELEMENTS_AUDIT_PKG" AS
/* $Header: cskbelab.pls 120.1 2005/08/09 12:10:18 mkettle noship $ */
/*======================================================================+
 |                Copyright (c) 1999 Oracle Corporation                 |
 |                   Redwood Shores, California, USA                    |
 |                        All rights reserved.                          |
 +======================================================================+
 | History
 |  01-APR-2001 Bate Yu  created
 |  14-AUG-2002 KLOU  (SEDATE)
 |              1. Add logic in create_element_CLOB and
 |                 update_element_CLOB to validate statement_type.
 |  24-JAN-2003 MKETTLE  Added Update_Statement
 |  29-JUL-2003 MKETTLE  Added Update_Statement_Admin to be used by the
 |                       Global Statement Update in OA
 |  24-SEP-2003 MKETTLE  Added ASAP indexing to Update_Statement_Admin
 |  06-OCT-2003 MKETTLE  Changed Update_Statement_Admin to cater for a
 |                       duplicate found within the same solution
 |  31-OCT-2003 MKETTLE  In GSU before creating a new Statement check
 |                       if the Statement has changed first
 |  18-Nov-2003 MKETTLE  Cleanup for 11.5.10
 |                       - Obsolete unused apis
 |                       - Moved table Handlers to ELEMENTS_PKG
 |  25-Nov-2003 MKETTLE  Added Obsolete_Unused_Statements
 |  21-Apr-2004 MKETTLE  Fix for Bug 3576066
 |  22-Apr-2004 MKETTLE  Added rollback/savepoint: Update_Statement_Admin
 |  21-Apr-2005 MKETTLE  Commented Cursor Check_Statement_Cat_Grp_Usage in
 |                       Update_Statement_Admin, since not used (Perf Rep)
 |  17-May-2005 MKETTLE Cleanup - Removed unused apis + cursors
 |                 apis removed in 115.52:
 |                  Get_Previous_Version_id
 |                  Get_Lock_Info
 |                  Locked_By
 |                  Incr_Element_Element
 |  09-Aug-2005 MKETTLE Resized Elements_Tl.Name variable to 2000 in
 |                      api Is_Element_Created_Dup
 +======================================================================*/

 -- return other_element_id if duplicate can be reused
 -- return 0 if no duplicate found
 FUNCTION Is_Element_Created_Dup(
   P_ELEMENT_ID IN NUMBER)
 RETURN NUMBER
 IS
  l_element_number VARCHAR(30);
  l_element_type_id NUMBER(15);
  l_access_level NUMBER(4);
  l_name VARCHAR2(2000);
  l_desc CLOB;

 BEGIN
  SELECT b.element_number, b.element_type_id, b.access_level, tl.name, tl.description
    INTO l_element_number, l_element_type_id, l_access_level, l_name, l_desc
    FROM CS_KB_ELEMENTS_B b,
         CS_KB_ELEMENTS_TL tl
   WHERE b.element_id = tl.element_id
     AND tl.language = USERENV('LANG')
     AND b.element_id = p_element_id;

  RETURN Is_Element_Dup ( l_element_number,
                          l_access_level,
                          l_element_type_id,
                          l_name,
                          l_desc);

 END Is_Element_Created_Dup;


 -- return other_element_id if duplicate can be reused
 -- return 0 if no duplicate found
 FUNCTION Is_Element_Dup  (
   P_ELEMENT_NUMBER  VARCHAR2,
   P_ACCESS_LEVEL    NUMBER,
   P_ELEMENT_TYPE_ID NUMBER,
   P_ELEMENT_NAME    VARCHAR2,
   P_ELEMENT_DESC CLOB)
 RETURN NUMBER
 IS
  CURSOR cur_ele_name (c_element_number  IN VARCHAR2,
                       c_name            IN VARCHAR2,
                       c_element_type_id IN NUMBER,
                       c_access_level    IN NUMBER ) IS
   SELECT tl.element_id,
          tl.description,
          b.status
   FROM CS_KB_ELEMENTS_TL tl,
        CS_KB_ELEMENTS_B b
   WHERE tl.name = c_name
   AND tl.language = USERENV('LANG')
   AND tl.element_id = b.element_id
   AND b.element_number <> c_element_number
   AND b.status = 'PUBLISHED'
   AND b.element_type_id = c_element_type_id
   AND b.access_level = c_access_level;

 BEGIN

  FOR rec in cur_ele_name (p_element_number,
                           p_element_name,
                           p_element_type_id,
                           p_access_level) LOOP

    IF DBMS_LOB.GETLENGTH(p_element_desc) > 0 AND
       rec.description IS NULL THEN

       NULL;

    ELSIF (p_element_desc IS NULL AND rec.description IS NULL) OR
          (p_element_desc IS NULL AND (DBMS_LOB.GETLENGTH(rec.description) = 0) ) OR
          ((DBMS_LOB.GETLENGTH(p_element_desc) = 0) AND rec.description IS NULL ) OR
          (DBMS_LOB.COMPARE(p_element_desc, rec.description) = 0 ) THEN

       RETURN rec.element_id;

    END IF;

  END LOOP;

  RETURN 0;

 END Is_Element_Dup;


 -- return other_element_id if duplicate can be reused
 -- return 0 if no duplicate found
 FUNCTION Is_Element_Updated_Dup(
   P_ELEMENT_ID IN NUMBER)
 RETURN NUMBER
 IS
 BEGIN
  RETURN Is_Element_Created_Dup(p_element_id);
 END Is_Element_Updated_Dup;


 FUNCTION Get_Element_Number(
   P_ELEMENT_ID IN NUMBER)
 RETURN VARCHAR2
 IS
  l_element_number VARCHAR2(30);

 BEGIN

  SELECT element_number
  INTO l_element_number
  FROM CS_KB_ELEMENTS_B
  WHERE element_id = p_element_id;

  RETURN l_element_number;

 END Get_Element_Number;


 FUNCTION Get_Latest_Version_Id(
   P_ELEMENT_NUMBER IN VARCHAR2)
 RETURN NUMBER IS

 l_latest_version_id NUMBER;

 BEGIN
  SELECT MAX(element_id)
  INTO l_latest_version_id
  FROM CS_KB_ELEMENTS_B
  WHERE element_number = p_element_number;
  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  RETURN l_latest_version_id;

 END Get_Latest_Version_Id;


 PROCEDURE Get_Who(
   X_SYSDATE  OUT NOCOPY DATE,
   X_USER_ID  OUT NOCOPY NUMBER,
   X_LOGIN_ID OUT NOCOPY NUMBER)
 IS
 BEGIN
  x_sysdate := SYSDATE;
  x_user_id := FND_GLOBAL.user_id;
  x_login_id := FND_GLOBAL.login_id;
 END Get_Who;


 --
 --  create element. RETURNs element_id.
 --  accepts VARCHAR2
 --  use that to create clob AND call Create_Element_CLOB
 FUNCTION Create_Element(
   P_ELEMENT_TYPE_ID    IN NUMBER,
   P_DESC               IN VARCHAR2,
   P_NAME               IN VARCHAR2,
   P_STATUS             IN VARCHAR2,
   P_ACCESS_LEVEL       IN NUMBER,
   P_ATTRIBUTE_CATEGORY IN VARCHAR2,
   P_ATTRIBUTE1         IN VARCHAR2,
   P_ATTRIBUTE2         IN VARCHAR2,
   P_ATTRIBUTE3         IN VARCHAR2,
   P_ATTRIBUTE4         IN VARCHAR2,
   P_ATTRIBUTE5         IN VARCHAR2,
   P_ATTRIBUTE6         IN VARCHAR2,
   P_ATTRIBUTE7         IN VARCHAR2,
   P_ATTRIBUTE8         IN VARCHAR2,
   P_ATTRIBUTE9         IN VARCHAR2,
   P_ATTRIBUTE10        IN VARCHAR2,
   P_ATTRIBUTE11        IN VARCHAR2,
   P_ATTRIBUTE12        IN VARCHAR2,
   P_ATTRIBUTE13        IN VARCHAR2,
   P_ATTRIBUTE14        IN VARCHAR2,
   P_ATTRIBUTE15        IN VARCHAR2,
   P_START_ACTIVE_DATE  IN DATE,
   P_END_ACTIVE_DATE    IN DATE,
   P_CONTENT_TYPE       IN VARCHAR2 )
  RETURN NUMBER
  IS
   l_offset NUMBER;
   l_amt    NUMBER;
   l_clob CLOB;
   l_element_id NUMBER;
   l_date  DATE;
   l_created_by NUMBER;
   l_login NUMBER;
   l_rowid VARCHAR2(30);

 BEGIN
  -- check params
  IF(p_element_type_id IS NULL OR p_name IS NULL) THEN
    RETURN -1;
  END IF;

  IF(p_desc IS NOT NULL) THEN
    DBMS_LOB.createtemporary(l_clob, true, DBMS_LOB.session);
    l_offset := 1;
    l_amt := length(p_desc);
    DBMS_LOB.write(l_clob, l_amt, l_offset, p_desc);
  END IF;

  l_element_id := Create_Element_CLOB(
	      p_element_type_id    => p_element_type_id,
	      p_desc               => l_clob,
	      p_name               => p_name,
	      p_status             => p_status,
	      p_access_level       => p_access_level,
	      p_attribute_category => p_attribute_category,
	      p_attribute1         => p_attribute1,
	      p_attribute2         => p_attribute2,
	      p_attribute3         => p_attribute3,
	      p_attribute4         => p_attribute4,
	      p_attribute5         => p_attribute5,
	      p_attribute6         => p_attribute6,
	      p_attribute7         => p_attribute7,
	      p_attribute8         => p_attribute8,
	      p_attribute9         => p_attribute9,
	      p_attribute10        => p_attribute10,
	      p_attribute11        => p_attribute11,
	      p_attribute12        => p_attribute12,
	      p_attribute13        => p_attribute13,
	      p_attribute14        => p_attribute14,
	      p_attribute15        => p_attribute15,
	      p_start_active_date  => p_start_active_date,
	      p_end_active_date    => p_end_active_date,
	      p_content_type       => p_content_type );

  IF(p_desc IS NOT NULL) THEN
    DBMS_LOB.freetemporary(l_clob);
  END IF;

  RETURN l_element_id;

 EXCEPTION
  WHEN FND_API.g_exc_error THEN
    RETURN ERROR_STATUS;
  WHEN others THEN
    IF(l_clob IS NOT NULL) THEN
      DBMS_LOB.freetemporary(l_clob);
    END IF;
    FND_MESSAGE.set_name('CS', 'CS_KB_C_UNEXP_ERR');
    RETURN ERROR_STATUS;

 END Create_Element;


 --
 -- create element given element_type_id AND desc clob
 -- other params are NOT used FOR now.
 -- IF error, RETURNs error.
 --
 FUNCTION Create_Element_CLOB(
   P_ELEMENT_TYPE_ID    IN NUMBER,
   P_DESC               IN CLOB,
   P_NAME               IN VARCHAR2,
   P_STATUS             IN VARCHAR2,
   P_ACCESS_LEVEL       IN NUMBER,
   P_ATTRIBUTE_CATEGORY IN VARCHAR2,
   P_ATTRIBUTE1         IN VARCHAR2,
   P_ATTRIBUTE2         IN VARCHAR2,
   P_ATTRIBUTE3         IN VARCHAR2,
   P_ATTRIBUTE4         IN VARCHAR2,
   P_ATTRIBUTE5         IN VARCHAR2,
   P_ATTRIBUTE6         IN VARCHAR2,
   P_ATTRIBUTE7         IN VARCHAR2,
   P_ATTRIBUTE8         IN VARCHAR2,
   P_ATTRIBUTE9         IN VARCHAR2,
   P_ATTRIBUTE10        IN VARCHAR2,
   P_ATTRIBUTE11        IN VARCHAR2,
   P_ATTRIBUTE12        IN VARCHAR2,
   P_ATTRIBUTE13        IN VARCHAR2,
   P_ATTRIBUTE14        IN VARCHAR2,
   P_ATTRIBUTE15        IN VARCHAR2,
   P_START_ACTIVE_DATE  IN DATE,
   P_END_ACTIVE_DATE    IN DATE,
   P_CONTENT_TYPE       IN VARCHAR2 )
 RETURN NUMBER
 IS

  l_element_id NUMBER;
  l_return_status VARCHAR2(1);
  l_msg_data VARCHAR2(2000);
  l_msg_count NUMBER;

 BEGIN

  l_element_id := null;

  Create_Statement( x_element_id         => l_element_id,
                    p_element_type_id    => p_element_type_id,
                    p_name               => p_name,
                    p_desc               => p_desc,
                    p_status             => p_status,
                    p_access_level       => p_access_level,
                    p_attribute_category => p_attribute_category,
                    p_attribute1         => p_attribute1,
                    p_attribute2         => p_attribute2,
                    p_attribute3         => p_attribute3,
                    p_attribute4         => p_attribute4,
                    p_attribute5         => p_attribute5,
                    p_attribute6         => p_attribute6,
                    p_attribute7         => p_attribute7,
                    p_attribute8         => p_attribute8,
                    p_attribute9         => p_attribute9,
                    p_attribute10        => p_attribute10,
                    p_attribute11        => p_attribute11,
                    p_attribute12        => p_attribute12,
                    p_attribute13        => p_attribute13,
                    p_attribute14        => p_attribute14,
                    p_attribute15        => p_attribute15,
                    p_start_active_date  => p_start_active_date,
                    p_end_active_date    => p_end_active_date,
                    p_content_type       => p_content_type,
                    x_return_status      => l_return_status,
                    x_msg_data           => l_msg_data,
                    x_msg_count          => l_msg_count);

  RETURN l_element_id;

 EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.set_name('CS', 'CS_KB_C_UNEXP_ERR');
    RETURN ERROR_STATUS;
 END Create_Element_CLOB;


 FUNCTION Update_Element(
   P_ELEMENT_ID         IN NUMBER,
   P_ELEMENT_NUMBER     IN VARCHAR2,
   P_ELEMENT_TYPE_ID    IN NUMBER,
   P_DESC               IN VARCHAR2,
   P_NAME               IN VARCHAR2,
   P_STATUS             IN VARCHAR2,
   P_ACCESS_LEVEL       IN NUMBER,
   P_ATTRIBUTE_CATEGORY IN VARCHAR2,
   P_ATTRIBUTE1         IN VARCHAR2,
   P_ATTRIBUTE2         IN VARCHAR2,
   P_ATTRIBUTE3         IN VARCHAR2,
   P_ATTRIBUTE4         IN VARCHAR2,
   P_ATTRIBUTE5         IN VARCHAR2,
   P_ATTRIBUTE6         IN VARCHAR2,
   P_ATTRIBUTE7         IN VARCHAR2,
   P_ATTRIBUTE8         IN VARCHAR2,
   P_ATTRIBUTE9         IN VARCHAR2,
   P_ATTRIBUTE10        IN VARCHAR2,
   P_ATTRIBUTE11        IN VARCHAR2,
   P_ATTRIBUTE12        IN VARCHAR2,
   P_ATTRIBUTE13        IN VARCHAR2,
   P_ATTRIBUTE14        IN VARCHAR2,
   P_ATTRIBUTE15        IN VARCHAR2,
   P_START_ACTIVE_DATE  IN DATE,
   P_END_ACTIVE_DATE    IN DATE,
   P_CONTENT_TYPE       IN VARCHAR2 )
 RETURN NUMBER
 IS
  l_offset NUMBER;
  l_amt    NUMBER;
  l_clob CLOB;
  l_ret NUMBER;
  l_date  DATE;
  l_updated_by NUMBER;
  l_login NUMBER;
  --l_count PLS_INTEGER;
 BEGIN
  -- validate params
  IF (p_element_number IS NULL) OR ( NOT p_element_type_id > 0) THEN
    RETURN -1;
  END IF;

  -- write desc to clob
  IF(p_desc IS NOT NULL) THEN
    DBMS_LOB.createtemporary(l_clob, true, DBMS_LOB.session);
    l_offset := 1;
    l_amt := length(p_desc);
    DBMS_LOB.write(l_clob, l_amt, l_offset, p_desc);
  END IF;

  l_ret := Update_Element_CLOB(
		    P_ELEMENT_ID         => p_element_id,
		    P_ELEMENT_NUMBER     => p_element_number,
		    P_ELEMENT_TYPE_ID    => p_element_type_id,
		    P_DESC               => l_clob,
		    P_NAME               => p_name,
		    P_STATUS             => p_status,
		    P_ACCESS_LEVEL       => p_access_level,
		    P_ATTRIBUTE_CATEGORY => p_attribute_category,
		    P_ATTRIBUTE1         => p_attribute1,
		    P_ATTRIBUTE2         => p_attribute2,
		    P_ATTRIBUTE3         => p_attribute3,
		    P_ATTRIBUTE4         => p_attribute4,
		    P_ATTRIBUTE5         => p_attribute5,
		    P_ATTRIBUTE6         => p_attribute6,
		    P_ATTRIBUTE7         => p_attribute7,
		    P_ATTRIBUTE8         => p_attribute8,
		    P_ATTRIBUTE9         => p_attribute9,
		    P_ATTRIBUTE10        => p_attribute10,
		    P_ATTRIBUTE11        => p_attribute11,
		    P_ATTRIBUTE12        => p_attribute12,
		    P_ATTRIBUTE13        => p_attribute13,
		    P_ATTRIBUTE14        => p_attribute14,
		    P_ATTRIBUTE15        => p_attribute15,
		    P_START_ACTIVE_DATE  => p_start_active_date,
		    P_END_ACTIVE_DATE    => p_end_active_date,
		    P_CONTENT_TYPE       => p_content_type );

  IF(p_desc IS NOT NULL) THEN
    DBMS_LOB.freetemporary(l_clob);
  END IF;

  RETURN l_ret;
 EXCEPTION
  WHEN others THEN
    IF(l_clob IS NOT NULL) THEN
      DBMS_LOB.freetemporary(l_clob);
    END IF;
    FND_MESSAGE.set_name('CS', 'CS_KB_C_UNEXP_ERR');
    RETURN ERROR_STATUS;
 END Update_Element;


 FUNCTION Update_Element_CLOB(
   p_element_id IN NUMBER,
   p_element_number IN VARCHAR2,
   p_element_type_id IN NUMBER,
   p_desc IN CLOB,
   p_name IN VARCHAR2,
   p_status IN VARCHAR2,
   p_access_level IN NUMBER,
   p_attribute_category IN VARCHAR2,
   p_attribute1 IN VARCHAR2,
   p_attribute2 IN VARCHAR2,
   p_attribute3 IN VARCHAR2,
   p_attribute4 IN VARCHAR2,
   p_attribute5 IN VARCHAR2,
   p_attribute6 IN VARCHAR2,
   p_attribute7 IN VARCHAR2,
   p_attribute8 IN VARCHAR2,
   p_attribute9 IN VARCHAR2,
   p_attribute10 IN VARCHAR2,
   p_attribute11 IN VARCHAR2,
   p_attribute12 IN VARCHAR2,
   p_attribute13 IN VARCHAR2,
   p_attribute14 IN VARCHAR2,
   p_attribute15 IN VARCHAR2,
   p_start_active_date IN DATE,
   p_end_active_date IN DATE,
   p_content_type IN VARCHAR2 )
 RETURN NUMBER
 IS

  l_return NUMBER;
  l_return_status VARCHAR2(1);
  l_msg_data VARCHAR2(2000);
  l_msg_count NUMBER;

 BEGIN
  Update_Statement(
		  p_element_id         => p_element_id,
		  p_element_number     => p_element_number,
		  p_element_type_id    => p_element_type_id,
		  p_desc               => p_desc,
		  p_name               => p_name,
		  p_status             => p_status,
		  p_access_level       => p_access_level,
		  p_attribute_category => p_attribute_category,
		  p_attribute1         => p_attribute1,
		  p_attribute2         => p_attribute2,
		  p_attribute3         => p_attribute3,
		  p_attribute4         => p_attribute4,
		  p_attribute5         => p_attribute5,
		  p_attribute6         => p_attribute6,
		  p_attribute7         => p_attribute7,
		  p_attribute8         => p_attribute8,
		  p_attribute9         => p_attribute9,
		  p_attribute10        => p_attribute10,
		  p_attribute11        => p_attribute11,
		  p_attribute12        => p_attribute12,
		  p_attribute13        => p_attribute13,
		  p_attribute14        => p_attribute14,
		  p_attribute15        => p_attribute15,
		  p_start_active_date  => p_start_active_date,
		  p_end_active_date    => p_end_active_date,
		  p_content_type       => p_content_type,
		  x_return             => l_return,
		  x_return_status      => l_return_status,
		  x_msg_data           => l_msg_data,
		  x_msg_count          => l_msg_count);

  RETURN l_return;

 EXCEPTION
  WHEN others THEN
    FND_MESSAGE.set_name('CS', 'CS_KB_C_UNEXP_ERR');
    RETURN ERROR_STATUS;
 END Update_Element_CLOB;


 --
 -- DELETE element
 --   RETURNs error IF element IS used by some solution
 --   OR IF element linked to external
 --
 FUNCTION Delete_Element(
   P_ELEMENT_NUMBER IN VARCHAR2)
 RETURN NUMBER
 IS
  l_ret NUMBER;
  l_count PLS_INTEGER;
 BEGIN
  IF p_element_number IS NULL THEN
    FND_MESSAGE.set_name('CS', 'CS_KB_C_MISS_PARAM');
    RETURN ERROR_STATUS;
  END IF;

  SELECT COUNT(*) INTO l_count
    FROM CS_KB_SET_ELES
    WHERE element_id = Get_Latest_Version_Id(p_element_number);
  IF(l_count > 0) THEN
    FND_MESSAGE.set_name('CS', 'CS_KB_C_ELE_IN_SET_ERR');
    RETURN ERROR_STATUS;
  END IF;

  SELECT COUNT(*) INTO l_count
    FROM CS_KB_ELEMENT_LINKS
    WHERE element_id = Get_Latest_Version_Id(p_element_number);
  IF(l_count > 0) THEN
    FND_MESSAGE.set_name('CS', 'CS_KB_C_ELE_IN_LINK_ERR');
    RETURN ERROR_STATUS;
  END IF;

  --clean cs_kb_elements_audit_b , cs_kb_elements_audit_tl
  CS_KB_ELEMENTS_PKG.Delete_Row(x_element_number => p_element_number);

  RETURN OKAY_STATUS;
 END Delete_Element;


 PROCEDURE Create_Statement(
   X_ELEMENT_ID         IN OUT NOCOPY NUMBER,
   P_ELEMENT_TYPE_ID    IN NUMBER,
   P_NAME               IN VARCHAR2,
   P_DESC               IN CLOB,
   P_STATUS             IN VARCHAR2,
   P_ACCESS_LEVEL       IN NUMBER,
   P_ATTRIBUTE_CATEGORY IN VARCHAR2,
   P_ATTRIBUTE1         IN VARCHAR2,
   P_ATTRIBUTE2         IN VARCHAR2,
   P_ATTRIBUTE3         IN VARCHAR2,
   P_ATTRIBUTE4         IN VARCHAR2,
   P_ATTRIBUTE5         IN VARCHAR2,
   P_ATTRIBUTE6         IN VARCHAR2,
   P_ATTRIBUTE7         IN VARCHAR2,
   P_ATTRIBUTE8         IN VARCHAR2,
   P_ATTRIBUTE9         IN VARCHAR2,
   P_ATTRIBUTE10        IN VARCHAR2,
   P_ATTRIBUTE11        IN VARCHAR2,
   P_ATTRIBUTE12        IN VARCHAR2,
   P_ATTRIBUTE13        IN VARCHAR2,
   P_ATTRIBUTE14        IN VARCHAR2,
   P_ATTRIBUTE15        IN VARCHAR2,
   P_START_ACTIVE_DATE  IN DATE,
   P_END_ACTIVE_DATE    IN DATE,
   P_CONTENT_TYPE       IN VARCHAR2,
   X_RETURN_STATUS      OUT NOCOPY VARCHAR2,
   X_MSG_DATA           OUT NOCOPY VARCHAR2,
   X_MSG_COUNT          OUT NOCOPY NUMBER )
 IS

  l_element_number VARCHAR2(30);
  l_element_id NUMBER;
  l_date  DATE;
  l_created_by NUMBER;
  l_login NUMBER;
  l_rowid VARCHAR2(30);
  l_count PLS_INTEGER;
  l_status VARCHAR2(30);
  --SEDATE
  l_dummy   VARCHAR2(1) := null;

  CURSOR check_active_type_csr(p_element_type_id IN NUMBER) IS
    SELECT 'X'
    FROM cs_kb_element_types_b
    WHERE element_type_id = p_element_type_id
    AND trunc(sysdate) BETWEEN trunc(nvl(start_date_active, sysdate))
    AND trunc(nvl(end_date_active, sysdate));

 BEGIN
  X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
  -- check params
  IF(p_element_type_id IS NULL OR p_name IS NULL) THEN
       FND_MSG_PUB.initialize;
       FND_MESSAGE.set_name('CS', 'CS_KB_C_MISS_PARAM');
       FND_MSG_PUB.ADD;
       X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
       X_ELEMENT_ID  := -1;
       FND_MSG_PUB.Count_And_Get(p_encoded	=> FND_API.G_FALSE ,
                                 p_count    => x_msg_count,
                                 p_data     => x_msg_data);

  ELSE
    -- IF type exists
    SELECT COUNT(*) INTO l_count
    FROM CS_KB_ELEMENT_TYPES_B
    WHERE element_type_id = p_element_type_id;

    IF(l_count <1) THEN
       FND_MSG_PUB.initialize;
       FND_MESSAGE.set_name('CS', 'CS_KB_C_INVALID_ELE_TYPE_ID');
       FND_MSG_PUB.ADD;
       X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
       X_ELEMENT_ID   := -2;
       FND_MSG_PUB.Count_And_Get(p_encoded	=> FND_API.G_FALSE ,
                                 p_count    => x_msg_count,
                                 p_data     => x_msg_data);
    ELSE
      -- SEDATE
      Open check_active_type_csr(p_element_type_id);
      Fetch check_active_type_csr Into l_dummy;
      Close check_active_type_csr;

      If l_dummy Is Null Then
       FND_MSG_PUB.initialize;
       FND_MESSAGE.set_name('CS', 'CS_KB_EXPIRED_STMT_TYPE');
       FND_MSG_PUB.ADD;
       X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
       X_ELEMENT_ID   := -3;
       FND_MSG_PUB.Count_And_Get(p_encoded	=> FND_API.G_FALSE ,
                                 p_count    => x_msg_count,
                                 p_data     => x_msg_data);
      ELSE

        IF x_element_id is null THEN
          SELECT CS_KB_ELEMENTS_S.NEXTVAL INTO l_element_id FROM DUAL;
          x_element_id := l_element_id;
        END IF;

        SELECT TO_CHAR(CS_KB_ELEMENT_NUMBER_S.NEXTVAL) INTO l_element_number FROM DUAL;
        LOOP
          SELECT COUNT(element_number) INTO l_count
          FROM CS_KB_ELEMENTS_B
          WHERE element_number = l_element_number;
          EXIT WHEN l_count = 0;
          SELECT TO_CHAR(CS_KB_ELEMENT_NUMBER_S.NEXTVAL) INTO l_element_number FROM DUAL;
        END LOOP;

        IF x_element_id IS NULL OR l_element_number IS NULL THEN
          FND_MSG_PUB.initialize;
          FND_MESSAGE.set_name('CS', 'CS_KB_C_MISS_PARAM');
          FND_MSG_PUB.ADD;
          X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
          X_ELEMENT_ID   := -1;
          FND_MSG_PUB.Count_And_Get(p_encoded	=> FND_API.G_FALSE ,
                                    p_count     => x_msg_count,
                                    p_data      => x_msg_data);
        ELSE

          Get_Who(l_date, l_created_by, l_login);

          IF p_status IS NULL THEN
            l_status := 'DRAFT';
          ELSE
            l_status := p_status;
          END IF;


          CS_KB_ELEMENTS_PKG.Insert_Row(
             x_rowid              => l_rowid,
             x_element_id         => x_element_id,
             x_element_number     => l_element_number,
             x_element_type_id    => p_element_type_id,
             x_element_name       => NULL,
             x_group_flag         => NULL,
             x_status             => l_status,
             x_access_level       => p_access_level,
             x_name               => p_name,
             x_description        => p_desc,
             x_creation_date      => l_date,
             x_created_by         => l_created_by,
             x_last_update_date   => l_date,
             x_last_updated_by    => l_created_by,
             x_last_update_login  => l_login,
             x_locked_by          => NULL,
             x_lock_date          => NULL,
             x_attribute_category => p_attribute_category,
             x_attribute1         => p_attribute1,
             x_attribute2         => p_attribute2,
             x_attribute3         => p_attribute3,
             x_attribute4         => p_attribute4,
             x_attribute5         => p_attribute5,
             x_attribute6         => p_attribute6,
             x_attribute7         => p_attribute7,
             x_attribute8         => p_attribute8,
             x_attribute9         => p_attribute9,
             x_attribute10        => p_attribute10,
             x_attribute11        => p_attribute11,
             x_attribute12        => p_attribute12,
             x_attribute13        => p_attribute13,
             x_attribute14        => p_attribute14,
             x_attribute15        => p_attribute15,
             x_start_active_date  => p_start_active_date,
             x_end_active_date    => p_end_active_date,
             x_content_type       => p_content_type );

          X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

        END IF;

      END IF;

    END IF;

  END IF;

 EXCEPTION
  WHEN others THEN
    FND_MESSAGE.set_name('CS', 'CS_KB_C_UNEXP_ERR');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                              p_data => x_msg_data);
 END Create_Statement;


 FUNCTION create_clob
 RETURN CLOB
 IS
  c1 CLOB;
 BEGIN

  DBMS_LOB.CREATETEMPORARY(c1,true);
  DBMS_LOB.OPEN(c1,dbms_lob.lob_readwrite);
  DBMS_LOB.WRITE(c1,1,1,' ');
  RETURN c1;

 END create_clob;


 PROCEDURE Update_Statement(
   P_ELEMENT_ID         IN         NUMBER,
   P_ELEMENT_NUMBER     IN         VARCHAR2,
   P_ELEMENT_TYPE_ID    IN         NUMBER,
   P_DESC               IN         CLOB,
   P_NAME               IN         VARCHAR2,
   P_STATUS             IN         VARCHAR2,
   P_ACCESS_LEVEL       IN         NUMBER,
   P_ATTRIBUTE_CATEGORY IN         VARCHAR2,
   P_ATTRIBUTE1         IN         VARCHAR2,
   P_ATTRIBUTE2         IN         VARCHAR2,
   P_ATTRIBUTE3         IN         VARCHAR2,
   P_ATTRIBUTE4         IN         VARCHAR2,
   P_ATTRIBUTE5         IN         VARCHAR2,
   P_ATTRIBUTE6         IN         VARCHAR2,
   P_ATTRIBUTE7         IN         VARCHAR2,
   P_ATTRIBUTE8         IN         VARCHAR2,
   P_ATTRIBUTE9         IN         VARCHAR2,
   P_ATTRIBUTE10        IN         VARCHAR2,
   P_ATTRIBUTE11        IN         VARCHAR2,
   P_ATTRIBUTE12        IN         VARCHAR2,
   P_ATTRIBUTE13        IN         VARCHAR2,
   P_ATTRIBUTE14        IN         VARCHAR2,
   P_ATTRIBUTE15        IN         VARCHAR2,
   P_START_ACTIVE_DATE  IN         DATE,
   P_END_ACTIVE_DATE    IN         DATE,
   P_CONTENT_TYPE       IN         VARCHAR2,
   X_RETURN             OUT NOCOPY NUMBER,
   X_RETURN_STATUS      OUT NOCOPY VARCHAR2,
   X_MSG_DATA           OUT NOCOPY VARCHAR2,
   X_MSG_COUNT          OUT NOCOPY NUMBER  )
 IS

  l_date  DATE;
  l_updated_by NUMBER;
  l_login NUMBER;
  l_count PLS_INTEGER;

  --SEDATE
  l_dummy   VARCHAR2(1) := null;
  CURSOR check_active_type_csr(p_element_type_id IN NUMBER) Is
   SELECT 'X'
   FROM cs_kb_element_types_b
   WHERE element_type_id = p_element_type_id
   AND trunc(sysdate) BETWEEN trunc(nvl(start_date_active, sysdate))
                         AND trunc(nvl(end_date_active, sysdate));

  CURSOR validate_old_type_used_csr(p_element_type_id IN NUMBER,
                                    p_element_id  IN NUMBER) IS
   SELECT 'x'
   FROM CS_KB_ELEMENTS_B
   WHERE element_id = p_element_id
   AND element_type_id = p_element_type_id;

 BEGIN
  X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
  X_RETURN := -8;

  -- validate params
  IF (p_element_id IS NULL) OR ( NOT p_element_type_id > 0) THEN
    X_RETURN := -1; -- 'CS_KB_C_MISS_PARAM'
    FND_MSG_PUB.initialize;
    FND_MESSAGE.set_name('CS', 'CS_KB_C_MISS_PARAM');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);
  ELSE

    -- IF type exists
    SELECT COUNT(*) INTO l_count
    FROM CS_KB_ELEMENT_TYPES_B
    WHERE element_type_id = p_element_type_id;

    IF(l_count <1) THEN
      X_RETURN := -2;
      FND_MSG_PUB.initialize;
      FND_MESSAGE.set_name('CS', 'CS_KB_C_INVALID_ELE_TYPE_ID');
      FND_MSG_PUB.ADD;
      X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                                p_count   => X_MSG_COUNT,
                                p_data    => X_MSG_DATA);
    ELSE
      -- SEDATE
      Open check_active_type_csr(p_element_type_id);
      Fetch check_active_type_csr Into l_dummy;
      Close check_active_type_csr;

      IF l_dummy Is Null Then
        -- Check whether the p_set_type_id is same as the set_type_id in the solution.
        -- If yes, let it pass because it is a modification to a solution of which the expired
        -- solution type was active at the time when the solution was created.
        Open validate_old_type_used_csr(p_element_type_id, p_element_id);
        Fetch validate_old_type_used_csr Into l_dummy;
        Close validate_old_type_used_csr;
        IF l_dummy Is Null Then
            X_RETURN := -3;
            FND_MSG_PUB.initialize;
            FND_MESSAGE.set_name('CS', 'CS_KB_END_DATED_TYPE');
            FND_MSG_PUB.ADD;
            X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                                      p_count   => X_MSG_COUNT,
                                      p_data    => X_MSG_DATA);

        END IF;
      END IF;
      --END SEDATE

      IF l_dummy is not null THEN
        --prepare data, THEN INSERT new ele
        get_who(l_date, l_updated_by, l_login);

        CS_KB_ELEMENTS_PKG.Update_Row(
             x_element_id         => p_element_id,
             x_element_number     => p_element_number,
             x_element_type_id    => p_element_type_id,
             x_element_name       => NULL,
             x_group_flag         => NULL,
             x_status             => p_status,
             x_access_level       => p_access_level,
             x_name               => p_name,
             x_description        => p_desc,
             x_last_update_date   => l_date,
             x_last_updated_by    => l_updated_by,
             x_last_update_login  => l_login,
             x_locked_by          => null,
             x_lock_date          => null,
             x_attribute_category => p_attribute_category,
             x_attribute1         => p_attribute1,
             x_attribute2         => p_attribute2,
             x_attribute3         => p_attribute3,
             x_attribute4         => p_attribute4,
             x_attribute5         => p_attribute5,
             x_attribute6         => p_attribute6,
             x_attribute7         => p_attribute7,
             x_attribute8         => p_attribute8,
             x_attribute9         => p_attribute9,
             x_attribute10        => p_attribute10,
             x_attribute11        => p_attribute11,
             x_attribute12        => p_attribute12,
             x_attribute13        => p_attribute13,
             x_attribute14        => p_attribute14,
             x_attribute15        => p_attribute15,
             x_start_active_date  => p_start_active_date,
             x_end_active_date    => p_end_active_date,
             x_content_type       => p_content_type );

        -- Mark the Solutions as updated
        UPDATE cs_kb_sets_b
        SET last_update_date = l_date,
            last_updated_by = l_updated_by,
            last_update_login = l_login
        WHERE set_id IN (SELECT set_id
                         FROM CS_KB_SET_ELES
                         WHERE element_id = p_element_id);

        X_RETURN := OKAY_STATUS;
        X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

      END IF; -- Type Not End Dated

    END IF; -- Element Type is valid

  END IF; --Required parameters passed in

 EXCEPTION
  WHEN OTHERS THEN
    X_RETURN := -7;--ERROR_STATUS;
    FND_MESSAGE.set_name('CS', 'CS_KB_C_UPDATE_ERR');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);
 END Update_Statement;


 PROCEDURE Update_Statement_Admin (
   P_ELEMENT_ID      IN         NUMBER,
   P_ELEMENT_NUMBER  IN         VARCHAR2,
   P_ACCESS_LEVEL    IN         NUMBER,
   P_ELEMENT_TYPE_ID IN         NUMBER,
   P_ELEMENT_NAME    IN         VARCHAR2,
   P_ELEMENT_DESC    IN         CLOB,
   P_CONTENT_TYPE    IN         VARCHAR2,
   X_RETURN_ELEMENT  OUT NOCOPY NUMBER,
   X_RETURN_STATUS   OUT NOCOPY VARCHAR2,
   X_MSG_DATA        OUT NOCOPY VARCHAR2,
   X_MSG_COUNT       OUT NOCOPY NUMBER ) IS

  CURSOR Get_Other_Stmt_Attributes IS
   SELECT status,
         attribute_category,
         attribute1,
         attribute2,
         attribute3,
         attribute4,
         attribute5,
         attribute6,
         attribute7,
         attribute8,
         attribute9,
         attribute10,
         attribute11,
         attribute12,
         attribute13,
         attribute14,
         attribute15
   FROM CS_KB_ELEMENTS_B
   WHERE Element_id = P_ELEMENT_ID;

  CURSOR Get_Current_Cat_Group_Solns IS
   SELECT distinct s.Set_id, s.Set_Number
   FROM CS_KB_SETS_B s,
        CS_KB_SET_ELES e,
        CS_KB_SET_CATEGORIES c,
        CS_KB_CAT_GROUP_DENORM d
   WHERE s.Set_id = e.Set_Id
   AND   e.Element_id = P_ELEMENT_ID
   AND   s.Set_id = c.Set_id
   AND   c.Category_id = d.Child_Category_id
   AND   d.Category_Group_Id = CS_KB_SECURITY_PVT.Get_Category_Group_Id
   AND   (s.Latest_Version_Flag = 'Y' OR s.Viewable_Version_Flag = 'Y');

  CURSOR Get_Curr_CG_Solns_Upd_Stmt (v_dup_id IN NUMBER) IS
   SELECT distinct s.Set_id, s.Set_Number
   FROM CS_KB_SETS_B s,
        CS_KB_SET_ELES e,
        CS_KB_SET_CATEGORIES c,
        CS_KB_CAT_GROUP_DENORM d
   WHERE s.Set_id = e.Set_Id
   AND   e.Element_id = P_ELEMENT_ID
   AND   s.Set_id = c.Set_id
   AND   c.Category_id = d.Child_Category_id
   AND   d.Category_Group_Id = CS_KB_SECURITY_PVT.Get_Category_Group_Id
   AND   (s.Latest_Version_Flag = 'Y' OR s.Viewable_Version_Flag = 'Y')
   AND NOT EXISTS (SELECT 'x'
                   FROM CS_KB_SET_ELES se
                   WHERE se.set_id = e.set_id
                   AND se.element_id = v_dup_id);

  CURSOR Get_Curr_CG_Solns_Rem_Stmt (v_dup_id IN NUMBER) IS
   SELECT distinct s.Set_id, s.Set_Number
   FROM CS_KB_SETS_B s,
        CS_KB_SET_ELES e,
        CS_KB_SET_CATEGORIES c,
        CS_KB_CAT_GROUP_DENORM d
   WHERE s.Set_id = e.Set_Id
   AND   e.Element_id = P_ELEMENT_ID
   AND   s.Set_id = c.Set_id
   AND   c.Category_id = d.Child_Category_id
   AND   d.Category_Group_Id = CS_KB_SECURITY_PVT.Get_Category_Group_Id
   AND   (s.Latest_Version_Flag = 'Y' OR s.Viewable_Version_Flag = 'Y')
   AND EXISTS (SELECT 'x'
               FROM CS_KB_SET_ELES se
               WHERE se.set_id = e.set_id
               AND se.element_id = v_dup_id);

  CURSOR Get_Element_Number IS
   SELECT Element_Number
   FROM   CS_KB_ELEMENTS_B
   WHERE  Element_id = P_ELEMENT_ID;


  CURSOR Stmt_In_Soln_Outside_Cur_CG IS
   SELECT count(distinct s.Set_Number)
   FROM CS_KB_SETS_VL s,
        CS_KB_SET_ELES e
   WHERE s.Set_id = e.Set_Id
   AND   e.Element_id = P_ELEMENT_ID
   AND   s.Latest_Version_Flag = 'Y'
   AND   s.Status <> 'OBS'
   AND   s.Set_Id IN (SELECT setb.Set_Id
                      FROM   CS_KB_SETS_B setb,
                             CS_KB_SET_ELES setele,
                             CS_KB_SET_CATEGORIES setcat,
                             CS_KB_CAT_GROUP_DENORM denorm
                      WHERE  setb.set_id = setele.Set_Id
                      AND    setele.Element_id = e.Element_id
                      AND    setb.Latest_Version_Flag = 'Y'
                      AND    setb.Status <> 'OBS'
                      AND   setb.Set_id = setcat.Set_id
                      AND   setcat.Category_id = denorm.Child_Category_id
                      AND   denorm.Category_Group_Id <> CS_KB_SECURITY_PVT.Get_Category_Group_Id
                      AND NOT EXISTS (SELECT 'x'
                                      FROM   CS_KB_SETS_B setb2,
                                             CS_KB_SET_CATEGORIES setcat2,
                                             CS_KB_CAT_GROUP_DENORM denorm2
                                      WHERE  setb2.set_id = setb.Set_Id
                                      AND    setb2.Latest_Version_Flag = 'Y'
                                      AND    setb2.Status <> 'OBS'
                                      AND   setb2.Set_id = setcat2.Set_id
                                      AND   setcat2.Category_id = denorm2.Child_Category_id
                                      AND   denorm2.Category_Group_Id =
                                            CS_KB_SECURITY_PVT.Get_Category_Group_Id )
                     );

  l_cg_usage_count NUMBER;
  l_dup_id NUMBER := NULL;
  l_dup_check_id NUMBER := NULL;
  l_status VARCHAR2(30);
  l_attribute_category VARCHAR2(30);
  l_attribute1 VARCHAR2(150);
  l_attribute2 VARCHAR2(150);
  l_attribute3 VARCHAR2(150);
  l_attribute4 VARCHAR2(150);
  l_attribute5 VARCHAR2(150);
  l_attribute6 VARCHAR2(150);
  l_attribute7 VARCHAR2(150);
  l_attribute8 VARCHAR2(150);
  l_attribute9 VARCHAR2(150);
  l_attribute10 VARCHAR2(150);
  l_attribute11 VARCHAR2(150);
  l_attribute12 VARCHAR2(150);
  l_attribute13 VARCHAR2(150);
  l_attribute14 VARCHAR2(150);
  l_attribute15 VARCHAR2(150);

  l_element_number VARCHAR2(30);
  l_new_element_id NUMBER;

  l_request_id number;
  l_return NUMBER;
  l_return_status VARCHAR2(1);
  l_msg_data VARCHAR2(2000);
  l_msg_count NUMBER;

  l_asap_idx_enabled varchar2(4) := null;

 BEGIN
  X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
  X_RETURN_ELEMENT := P_ELEMENT_ID;

  SAVEPOINT START_GSU;


  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'csk.plsql.CS_KB_ELEMENTS_AUDIT_PVT.Update_Statement_Admin.Start',
                   'Started Global Statement Update');
  END IF;

  -- Is the updated Statement now a Duplicate ?
  l_dup_id := Is_Element_Dup  ( P_ELEMENT_NUMBER  => P_ELEMENT_NUMBER,
                                P_ACCESS_LEVEL    => P_ACCESS_LEVEL,
                                P_ELEMENT_TYPE_ID => P_ELEMENT_TYPE_ID,
                                P_ELEMENT_NAME    => P_ELEMENT_NAME,
                                P_ELEMENT_DESC    => P_ELEMENT_DESC );

  -- If the api returns 0 then no duplicate exists
  -- else it returns an element_id


  IF l_dup_id <> 0 THEN
    -- A Duplicate Statement Exists for this update
    -- Update All Solutions within the Current Category Group to be
    -- associated to the Duplicate (Already existing Statement).
    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'csk.plsql.CS_KB_ELEMENTS_AUDIT_PVT.Update_Statement_Admin',
                     'A Duplicate Statement Exists for this update - UPD with Current CG');
    END IF;

    -- Bug 3576066 moved to above upd + delete
    cs_kb_sync_index_pkg.MARK_IDXS_ON_GLOBAL_STMT_UPD(l_dup_id);
    cs_kb_sync_index_pkg.MARK_IDXS_ON_GLOBAL_STMT_UPD(P_ELEMENT_ID);

    FOR solns IN Get_Curr_CG_Solns_Upd_Stmt (l_dup_id) LOOP
      -- This returns Solutions in the current Category Group
      -- to be updated. Only solutions that do not already
      -- contain the new statement will be returned

      UPDATE CS_KB_SET_ELES se
      SET se.ELEMENT_ID = l_dup_id,
          se.LAST_UPDATE_DATE = sysdate,
          se.LAST_UPDATED_BY = FND_GLOBAL.user_id,
          se.LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
      WHERE se.Element_Id = P_ELEMENT_ID
      AND   se.Set_Id = solns.Set_Id;

    END LOOP;

    FOR remstmts IN Get_Curr_CG_Solns_Rem_Stmt (l_dup_id) LOOP
      -- This returns Solutions in the current Category Group.
      -- These solutions already contain the new duplicate -
      -- therefore we will delete the original statement that
      -- was updated.

      DELETE FROM CS_KB_SET_ELES se
      WHERE se.Element_Id = P_ELEMENT_ID
      AND   se.Set_Id = remstmts.Set_Id;

    END LOOP;

    fnd_profile.get('CS_KB_ENABLE_ASAP_INDEXING', l_asap_idx_enabled);
    IF ( l_asap_idx_enabled = 'Y' )
    THEN
      CS_KB_SYNC_INDEX_PKG.request_sync_km_indexes( l_request_id, l_return_status );
    END IF;

    X_RETURN_ELEMENT    := l_dup_id;
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

  ELSE -- The Updated Statement is not a Duplicate

    /* -- Need to check Soln Usage !!!
    The following Api returns a count of the Number of Solutions that use
    the statement, where that Solution only exists in Category Groups
    outside of the current user Category Group

    -- If the Statement only resides on Solutions within the current CG then
    update the statement directly.

    -- If the Statement is used on Solutions outside of the current CG only, then these
    solutions should remain unchanged
    i.e. within the current CG a new Statement will be created and assoicated to the
    current CG solutions.
    Solutions outside of the current CG will continue to point to the original statement.

    -- If a Solution resides in multiple CG's then the statement will be updated directly
    and therefore the changed statement will be seen across CG's
    */

    OPEN  Stmt_In_Soln_Outside_Cur_CG;
    FETCH Stmt_In_Soln_Outside_Cur_CG INTO l_cg_usage_count;
    CLOSE Stmt_In_Soln_Outside_Cur_CG;
    --dbms_output.put_line('Usage Count : '||l_cg_usage_count);

    -- Check if any solns outside of current CG are affected
    -- if Yes - Create a new stmt and link solns within current CG to it
    --        - Leave solns outside of current CG to be linked to existing stmt
    -- if No  - Update as normal


    OPEN  Get_Other_Stmt_Attributes;
    FETCH Get_Other_Stmt_Attributes INTO  l_status, l_attribute_category, l_attribute1, l_attribute2,
                                          l_attribute3, l_attribute4,l_attribute5, l_attribute6,
                                          l_attribute7, l_attribute8, l_attribute9, l_attribute10,
                                          l_attribute11, l_attribute12, l_attribute13, l_attribute14,
                                          l_attribute15; --, l_content_type;
    CLOSE Get_Other_Stmt_Attributes;

    IF l_cg_usage_count = 0 THEN
      -- If Yes (count=0) - Statement only used in current Category Group - Update Statement as normal
      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'csk.plsql.CS_KB_ELEMENTS_AUDIT_PVT.Update_Statement_Admin',
                       'Statement only used in current Category Group - Update Statement');
      END IF;

      Update_Statement( p_element_id         => P_ELEMENT_ID,
                        p_element_number     => P_ELEMENT_NUMBER,
                        p_element_type_id    => P_ELEMENT_TYPE_ID,
                        p_desc               => P_ELEMENT_DESC,
                        p_name               => P_ELEMENT_NAME,
                        p_status             => l_status,
                        p_access_level       => P_ACCESS_LEVEL,
                        p_attribute_category => l_attribute_category,
                        p_attribute1         => l_attribute1,
                        p_attribute2         => l_attribute2,
                        p_attribute3         => l_attribute3,
                        p_attribute4         => l_attribute4,
                        p_attribute5         => l_attribute5,
                        p_attribute6         => l_attribute6,
                        p_attribute7         => l_attribute7,
                        p_attribute8         => l_attribute8,
                        p_attribute9         => l_attribute9,
                        p_attribute10        => l_attribute10,
                        p_attribute11        => l_attribute11,
                        p_attribute12        => l_attribute12,
                        p_attribute13        => l_attribute13,
                        p_attribute14        => l_attribute14,
                        p_attribute15        => l_attribute15,
                        p_start_active_date  => null,
                        p_end_active_date    => null,
                        p_content_type       => P_CONTENT_TYPE, --l_content_type,
                        x_return             => l_return,
                        x_return_status      => l_return_status,
                        x_msg_data           => l_msg_data,
                        x_msg_count          => l_msg_count);

      -- Set Output params
      X_RETURN_STATUS := l_return_status;
      X_MSG_DATA      := l_msg_data;
      X_MSG_COUNT     := l_msg_count;

      IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        cs_kb_sync_index_pkg.MARK_IDXS_ON_GLOBAL_STMT_UPD(P_ELEMENT_ID);

        fnd_profile.get('CS_KB_ENABLE_ASAP_INDEXING', l_asap_idx_enabled);
        IF ( l_asap_idx_enabled = 'Y' )
        THEN
          CS_KB_SYNC_INDEX_PKG.request_sync_km_indexes( l_request_id, l_return_status );
        END IF;

      END IF;

    ELSE -- Statement is shared across multiple Category Groups
         -- + Statement is not being updated Duplicate, therefore
         -- create a new Statement and associate within current CG
      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'csk.plsql.CS_KB_ELEMENTS_AUDIT_PVT.Update_Statement_Admin',
                       'Statement is shared across multiple Category Groups - Create New Stmt');
      END IF;

      -- Before creating a New Statement check that the Stmt is not being updated
      -- to itself ie no change to the original content
      l_dup_check_id := Is_Element_Dup  ( P_ELEMENT_NUMBER  => '-123',
                                          P_ACCESS_LEVEL    => P_ACCESS_LEVEL,
                                          P_ELEMENT_TYPE_ID => P_ELEMENT_TYPE_ID,
                                          P_ELEMENT_NAME    => P_ELEMENT_NAME,
                                          P_ELEMENT_DESC    => P_ELEMENT_DESC );

      IF l_dup_check_id <> P_ELEMENT_ID THEN

        Create_Statement( x_element_id         => l_new_element_id,
                          p_element_type_id    => p_element_type_id,
                          p_desc               => p_element_desc,
                          p_name               => p_element_name,
                          p_status             => l_status,
                          p_access_level       => p_access_level,
                          p_attribute_category => l_attribute_category,
                          p_attribute1         => l_attribute1,
                          p_attribute2         => l_attribute2,
                          p_attribute3         => l_attribute3,
                          p_attribute4         => l_attribute4,
                          p_attribute5         => l_attribute5,
                          p_attribute6         => l_attribute6,
                          p_attribute7         => l_attribute7,
                          p_attribute8         => l_attribute8,
                          p_attribute9         => l_attribute9,
                          p_attribute10        => l_attribute10,
                          p_attribute11        => l_attribute11,
                          p_attribute12        => l_attribute12,
                          p_attribute13        => l_attribute13,
                          p_attribute14        => l_attribute14,
                          p_attribute15        => l_attribute15,
                          p_content_type       => P_CONTENT_TYPE, --l_content_type,
                          x_return_status      => l_return_status,
                          x_msg_data           => l_msg_data,
                          x_msg_count          => l_msg_count);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          X_RETURN_ELEMENT    := NULL;
          X_RETURN_STATUS := l_return_status;
          X_MSG_DATA      := l_msg_data;
          X_MSG_COUNT     := l_msg_count;
        ELSE
          -- Api returned successful so continue

          -- Associate New Statement to All Solutions within the
          -- current Category Group only
          FOR solns IN Get_Current_Cat_Group_Solns LOOP

            UPDATE CS_KB_SET_ELES se
            SET se.ELEMENT_ID = l_new_element_id,
                se.LAST_UPDATE_DATE = sysdate,
                se.LAST_UPDATED_BY = FND_GLOBAL.user_id,
                se.LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
            WHERE se.Element_Id = P_ELEMENT_ID
            AND   se.Set_Id = solns.Set_Id;

          END LOOP;

          -- Reindex all Solutions effected
          CS_KB_SYNC_INDEX_PKG.Mark_Idxs_On_Global_Stmt_Upd(l_new_element_id);
    	  CS_KB_SYNC_INDEX_PKG.Mark_Idxs_On_Global_Stmt_Upd(P_ELEMENT_ID);

          fnd_profile.get('CS_KB_ENABLE_ASAP_INDEXING', l_asap_idx_enabled);
          IF ( l_asap_idx_enabled = 'Y' )
          THEN
            CS_KB_SYNC_INDEX_PKG.request_sync_km_indexes( l_request_id, l_return_status );
          END IF;

          X_RETURN_ELEMENT    := l_new_element_id;
          X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

        END IF;

      ELSE
        IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'csk.plsql.CS_KB_ELEMENTS_AUDIT_PVT.Update_Statement_Admin',
                   'Stmt is dup of the original - NO new Stmt created.');
        END IF;
        X_RETURN_ELEMENT    := P_ELEMENT_ID;
        X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
      END IF; --check if dup of itself

    END IF;

  END IF; -- Dup Check


  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'csk.plsql.CS_KB_ELEMENTS_AUDIT_PVT.Update_Statement_Admin.End',
                   'Finished Global Statement Update - '||X_RETURN_STATUS||'-'||X_RETURN_ELEMENT );
  END IF;

 EXCEPTION
  WHEN OTHERS THEN

    ROLLBACK TO START_GSU;

    IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, 'csk.plsql.CS_KB_ELEMENTS_AUDIT_PVT.Update_Statement_Admin.UNEX',
                     'Unexpected Exception-'||substrb(sqlerrm,1,200) );
    END IF;

    X_RETURN_ELEMENT := NULL;
    FND_MESSAGE.set_name('CS', 'CS_KB_C_UPDATE_ERR');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);
 END Update_Statement_Admin;


 PROCEDURE Obsolete_Unused_Statements (
   ERRBUF  OUT NOCOPY VARCHAR2,
   RETCODE OUT NOCOPY VARCHAR2 )
 IS

 CURSOR GET_ORPHANS IS
  SELECT E.element_id
  FROM CS_KB_ELEMENTS_B E
  WHERE E.status <> 'OBS'
  AND NOT EXISTS (SELECT 'x'
                  FROM CS_KB_SETS_B S,
                       CS_KB_SET_ELES SE
                  WHERE SE.Set_Id = S.Set_Id
                  AND   SE.Element_Id = E.Element_Id
                  AND   S.Status <> 'OBS'
                  AND  (S.Latest_Version_Flag = 'Y' OR S.Viewable_Version_Flag = 'Y')
                  );

 l_user  NUMBER := FND_GLOBAL.User_Id;
 l_login NUMBER := FND_GLOBAL.Login_Id;

 BEGIN

  FOR Statements IN GET_ORPHANS LOOP

    UPDATE CS_KB_ELEMENTS_B
    SET Status = 'OBS',
        Last_Update_Date = sysdate,
        Last_Updated_By = l_user,
        Last_Update_Login = l_login
    WHERE Element_Id = Statements.Element_id;

    UPDATE CS_KB_ELEMENTS_TL
    SET Composite_Text_Index = 'x',
        Last_Update_Date = sysdate,
        Last_Updated_By = l_user,
        Last_Update_Login = l_login
    WHERE Element_Id = Statements.Element_id;

  END LOOP;

  COMMIT;

  RETCODE := 0;

 EXCEPTION
  WHEN OTHERS THEN
    RETCODE := 2;
    ERRBUF := fnd_message.GET_STRING('CS','CS_KB_C_UNEXP_ERR')||' '||SQLERRM;
    FND_FILE.PUT_LINE(FND_FILE.LOG, ERRBUF);

 END Obsolete_Unused_Statements;

END CS_KB_ELEMENTS_AUDIT_PKG;

/
