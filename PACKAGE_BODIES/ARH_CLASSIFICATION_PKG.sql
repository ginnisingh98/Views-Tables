--------------------------------------------------------
--  DDL for Package Body ARH_CLASSIFICATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARH_CLASSIFICATION_PKG" AS
/*$Header: ARCLAASB.pls 115.4 2002/12/30 18:21:38 hyu noship $*/

-----------------------------------
-- Local procedure and functions --
-----------------------------------
/*-----------------------------------------------------+
 | Init_switch requires for forms                      |
 | 3 over loaded structures for VARCHAR2               |
 |                              NUMBER                 |
 |                              DATE                   |
 +-----------------------------------------------------*/
FUNCTION INIT_SWITCH
( p_date   IN DATE,
  p_switch IN VARCHAR2 DEFAULT 'NULL_GMISS')
RETURN DATE
IS
 res_date date;
BEGIN
 IF    p_switch = 'NULL_GMISS' THEN
   IF p_date IS NULL THEN
     res_date := FND_API.G_MISS_DATE;
   ELSE
     res_date := p_date;
   END IF;
 ELSIF p_switch = 'GMISS_NULL' THEN
   IF p_date = FND_API.G_MISS_DATE THEN
     res_date := NULL;
   ELSE
     res_date := p_date;
   END IF;
 ELSE
   res_date := TO_DATE('31/12/1800','DD/MM/RRRR');
 END IF;
 RETURN res_date;
END;

FUNCTION INIT_SWITCH
( p_char   IN VARCHAR2,
  p_switch IN VARCHAR2 DEFAULT 'NULL_GMISS')
RETURN VARCHAR2
IS
 res_char varchar2(2000);
BEGIN
 IF    p_switch = 'NULL_GMISS' THEN
   IF p_char IS NULL THEN
     return FND_API.G_MISS_CHAR;
   ELSE
     return p_char;
   END IF;
 ELSIF p_switch = 'GMISS_NULL' THEN
   IF p_char = FND_API.G_MISS_CHAR THEN
     return NULL;
   ELSE
     return p_char;
   END IF;
 ELSE
   return ('INCORRECT_P_SWITCH');
 END IF;
END;

FUNCTION INIT_SWITCH
( p_num   IN NUMBER,
  p_switch IN VARCHAR2 DEFAULT 'NULL_GMISS')
RETURN NUMBER
IS
 BEGIN
 IF    p_switch = 'NULL_GMISS' THEN
   IF p_num IS NULL THEN
     return FND_API.G_MISS_NUM;
   ELSE
     return p_num;
   END IF;
 ELSIF p_switch = 'GMISS_NULL' THEN
   IF p_num = FND_API.G_MISS_NUM THEN
     return NULL;
   ELSE
     return p_num;
   END IF;
 ELSE
   return ('9999999999');
 END IF;
END;



/*----------------------------------------+
 | local function compare                 |
 | parameter                              |
 |   date1 date                           |
 |   date2 date                           |
 | description                            |
 |   if date1 = date2 = NULL then return 2|
 |   if date1 = date2 then return 0       |
 |   if date1 > date2 then return 1       |
 |   if date1 < date2 then return -1      |
 +----------------------------------------*/
FUNCTION compare(
        date1 DATE,
        date2 DATE)
RETURN NUMBER
IS
  ldate1 date;
  ldate2 date;
BEGIN
  ldate1 := trunc(date1);
  ldate2 := trunc(date2);
        IF (ldate1 IS NULL AND ldate2 IS NULL) THEN
                RETURN 2;
        ELSIF (ldate2 IS NULL) THEN
                RETURN -1;
        ELSIF (ldate1 IS NULL) THEN
                RETURN 1;
        ELSIF ( ldate1 = ldate2 ) THEN
                RETURN 0;
        ELSIF ( ldate1 > ldate2 ) THEN
                RETURN 1;
        ELSE
                RETURN -1;
        END IF;
END compare;


------------------------------------
-- Public procedure and functions --
------------------------------------
/*-------------------------------------------------------+
 | Name : is_between                                     |
 |                                                       |
 | Description :                                         |
 |  Check if datex is between date1 and date2 inclusively|
 |  or exclusive                                         |
 |  INC = inclusive                                      |
 |  EXC = Exclusive                                      |
 |                                                       |
 | Parameter :                                           |
 |   datex     DATE                                      |
 |   date1     DATE                                      |
 |   date2     DATE                                      |
 |   inc_exc1  VARCHAR2 in 'INC','EXC'                   |
 |   inc_exc2  VARCHAR2 in 'INC','EXC'                   |
 | Return  :                                             |
 |  'Y' if datex is between date1 and date2              |
 |  'N' otherwise                                        |
 +-------------------------------------------------------*/
FUNCTION is_between
( datex     IN DATE,
  date1     IN DATE,
  date2     IN DATE,
  inc_exc1  IN VARCHAR2 DEFAULT 'INC',
  inc_exc2  IN VARCHAR2 DEFAULT 'INC')
 RETURN VARCHAR2
IS
  l_comp1   NUMBER;
  l_comp2   NUMBER;
  lres     VARCHAR2(1);
BEGIN
 l_comp1 := compare(datex, date1);
 l_comp2 := compare(date2, datex);
 IF l_comp1 = 2 OR l_comp2 = 2 THEN
    lres := 'Y';
 ELSIF  l_comp1 = 0 THEN
   IF inc_exc1 = 'INC' THEN
     lres := 'Y';
   ELSE
     lres := 'N';
   END IF;
 ELSIF l_comp2 = 0 THEN
   IF inc_exc2 = 'INC' THEN
     lres := 'Y';
   ELSE
     lres := 'N';
   END IF;
 ELSE
   IF l_comp1 = 1 and l_comp2 = 1 THEN
      lres := 'Y';
   ELSE
      lres := 'N';
   END IF;
 END IF;
 RETURN lres;
END is_between;


/*------------------------------------------------------+
 | Name : is_overlap                                    |
 |                                                      |
 | Description :                                        |
 |  check if period (s1 e1) overlaps (s2 e2)            |
 |  exclusive or inclusively                            |
 |  This function does not support s1 or s2 NULL        |
 |  start_Date null does not have any business meaning  |
 |                                                      |
 | Parameter :                                          |
 |  s1 DATE                                             |
 |  e1 DATE                                             |
 |  s2 DATE                                             |
 |  e2 DATE                                             |
 |  inc_exc  VARCHAR2 in 'INC', 'EXC'                   |
 | Return  :                                            |
 |  'Y' overlap                                         |
 |  'N' otherwise                                       |
 +------------------------------------------------------*/
FUNCTION is_overlap
(s1       IN DATE,
 e1       IN DATE,
 s2       IN DATE,
 e2       IN DATE,
 inc_exc  IN VARCHAR2)
RETURN VARCHAR2
IS
  l_comp   NUMBER;
  lres     VARCHAR2(1);
BEGIN
 IF s1 IS NULL OR s2 IS NULL THEN
   lres  := 'B';
 ELSE
   l_comp := compare(s1,s2);
   IF l_comp = 1 THEN
     IF is_between( s1,s2,e2,'INC',inc_exc) = 'Y' THEN
        lres := 'Y';
     ELSE
       lres := 'N';
     END IF;
   ELSIF l_comp = -1 THEN
     IF is_between( s2,s1,e1,'INC',inc_exc) = 'Y' THEN
       lres := 'Y';
     ELSE
       lres := 'N';
     END IF;
   ELSIF l_comp = 0 THEN
     IF is_between(e1,s2,e2,inc_exc,inc_exc) = 'Y' THEN
       lres := 'Y';
     ELSE
       lres := 'N';
     END IF;
   END IF;
 END IF;
 RETURN lres;
END is_overlap;


/*------------------------------------------------------+
 | Name : exist_overlap_assignment                      |
 |                                                      |
 | Description :                                        |
 |  check if there are any assignment overlapping       |
 |  a time period                                       |
 |                                                      |
 | Parameter :                                          |
 |   p_owner_table_name     table using classification  |
 |   p_owner_table_id       id frm that table           |
 |   p_class_category       class_category              |
 |   p_class_code           class code                  |
 |   p_start_date_active    start date of the assignment|
 |   p_end_date_active      end date of the assignment  |
 |   p_mode                 INSERT or UPDATE            |
 |   p_code_assignment_id   assignment id               |
 | Return  :                                            |
 |  'Y' overlap                                         |
 |  'N' otherwise                                       |
 +------------------------------------------------------*/
FUNCTION exist_overlap_assignment
( p_owner_table_name   IN VARCHAR2 DEFAULT NULL,
  p_owner_table_id     IN NUMBER   DEFAULT NULL,
  p_class_category     IN VARCHAR2 DEFAULT NULL,
  p_class_Code         IN VARCHAR2 DEFAULT NULL,
  p_start_date_active  IN DATE,
  p_end_date_active    IN DATE,
  p_mode               IN VARCHAR2,
  p_code_assignment_id IN NUMBER DEFAULT NULL)
RETURN VARCHAR2
IS
  CURSOR c_insert IS
  SELECT 'Y'
    FROM hz_code_assignments
   WHERE owner_table_id   = p_owner_table_id
     AND owner_table_name = p_owner_table_name
     AND class_category   = p_class_category
     AND class_code       = p_class_code
     AND is_overlap(start_date_active,
                    end_date_active,
                    p_start_date_active,
                    p_end_date_active,
                    decode(status,'I','EXC','INC'))='Y';

  CURSOR c_update IS
  SELECT 'Y'
    FROM hz_code_assignments a,
         hz_code_assignments b
   WHERE a.code_assignment_id  = p_code_assignment_id
     AND a.owner_table_name    = b.owner_table_name
     AND a.owner_table_id      = b.owner_table_id
     AND a.class_category      = b.class_category
     AND a.class_code          = b.class_code
     AND b.code_assignment_id <> a.code_assignment_id
     AND is_overlap(b.start_date_active,
                    b.end_date_active,
                    p_start_date_active,
                    p_end_date_active,
                    DECODE(b.status,'I','EXC','INC'))='Y';

  lres VARCHAR2(1);
BEGIN
  IF p_mode = 'INSERT' THEN
    OPEN c_insert;
    FETCH c_insert INTO lres;
    IF c_insert%NOTFOUND THEN
      lres := 'N';
    END IF;
    CLOSE c_insert;
  ELSIF p_mode = 'UPDATE' THEN
    OPEN c_update;
    FETCH c_update INTO lres;
    IF c_update%NOTFOUND THEN
      lres := 'N';
    END IF;
    CLOSE c_update;
  END IF;
  RETURN lres;
END;

/*------------------------------------------------------+
 | Name : is_assignment_active_today                    |
 |                                                      |
 | Description :                                        |
 |  Check if there is any assignment today              |
 |                                                      |
 | Parameter :                                          |
 |   p_owner_table_name     table using classification  |
 |   p_owner_table_id       id frm that table           |
 |   p_class_category       class_category              |
 |   p_class_code           class code                  |
 | Return  :                                            |
 |  Y if there are any                                  |
 |  N otherwise                                         |
 +------------------------------------------------------*/
FUNCTION is_assignment_active_today
( p_owner_table_name   IN VARCHAR2,
  p_owner_table_id     IN NUMBER,
  p_class_category     IN VARCHAR2,
  p_class_Code         IN VARCHAR2)
RETURN VARCHAR2
IS
  CURSOR c IS
  SELECT 'Y'
    FROM hz_code_assignments
   WHERE owner_table_id = p_owner_table_id
     AND owner_table_name = p_owner_table_name
     AND class_category   = p_class_category
     AND class_code       = p_class_code
     AND TRUNC(sysdate) >= start_date_active
     AND TRUNC(sysdate) <= NVL(end_Date_active,sysdate)
     AND DECODE(end_date_active,
                TRUNC(sysdate) ,NVL(status,'A'),'A') = 'A';
  lres  VARCHAR2(1);
BEGIN
  OPEN c;
  FETCH c INTO lres;
  IF c%NOTFOUND THEN
    lres := 'N';
  END IF;
  CLOSE c;
  RETURN lres;
END;

/*------------------------------------------------------+
 | Name : exist_assignment_not_ended                    |
 |                                                      |
 | Description :                                        |
 |  Check if there is any assignment without end date   |
 |                                                      |
 | Parameter :                                          |
 |   p_owner_table_name     table using classification  |
 |   p_owner_table_id       id from that table          |
 |   p_class_category       class_category              |
 |   p_class_code           class code                  |
 | Return  :                                            |
 |  Y if there are any                                  |
 |  N otherwise                                         |
 +------------------------------------------------------*/
FUNCTION exist_assignment_not_ended
( p_owner_table_name  IN VARCHAR2,
  p_owner_table_id    IN NUMBER,
  p_class_category    IN VARCHAR2,
  p_class_code        IN VARCHAR2)
RETURN VARCHAR2
IS
 CURSOR c1 IS
 SELECT 'Y'
   FROM hz_code_assignments
  WHERE owner_table_name = p_owner_table_name
    AND owner_table_id   = p_owner_table_id
    AND class_category   = p_class_category
    AND class_code       = p_class_code
    AND end_date_active IS NULL;
  lfound   VARCHAR2(1);
BEGIN
  OPEN c1;
  FETCH c1 INTO lfound;
  IF c1%NOTFOUND THEN
     lfound := 'N';
  END IF;
  CLOSE c1;
  RETURN lfound;
END;

/*------------------------------------------------------+
 | Name : exist_at_least_nb_assig                       |
 |                                                      |
 | Description :                                        |
 |  Check if there are more than a number of assignments|
 |                                                      |
 | Parameter :                                          |
 |   p_owner_table_name     table using classification  |
 |   p_owner_table_id       id frm that table           |
 |   p_class_category       class_category              |
 |   p_class_code           class code                  |
 |   p_nb                   Number of assignment        |
 | Return  :                                            |
 |  Y if there are any                                  |
 |  N otherwise                                         |
 +------------------------------------------------------*/
FUNCTION exist_at_least_nb_assig
( p_owner_table_name  IN VARCHAR2,
  p_owner_table_id    IN NUMBER,
  p_class_category    IN VARCHAR2,
  p_class_code        IN VARCHAR2,
  p_nb                IN NUMBER DEFAULT 2)
RETURN VARCHAR2
IS
  CURSOR c IS
  SELECT 'Y'
    FROM hz_code_assignments
   WHERE owner_table_name = p_owner_table_name
     AND owner_table_id   = p_owner_table_id
     AND class_category   = p_class_category
     AND class_code       = p_class_code;
  lcpt NUMBER;
  lres VARCHAR2(1);
  tst  VARCHAr2(1);
BEGIN
  lcpt  := 0;
  lres := 'N';
  OPEN c;
  LOOP
    FETCH c INTO tst;
    EXIT WHEN c%NOTFOUND;
    lcpt := lcpt + 1;
    IF lcpt >= p_nb THEN
      lres := 'Y';
      EXIT;
    END IF;
  END LOOP;
  CLOSE c;
  RETURN lres;
END;

/*------------------------------------------------------+
 | Name : Create_Code_assignment                        |
 |                                                      |
 | Description :                                        |
 |  Wrapper on the top TCA V2 API for                   |
 |  Code assignment creation .                          |
 |                                                      |
 | Parameter :                                          |
 |  From the record type                                |
 |   HZ_CLASSIFCIATION_V2PUB.CODE_ASSIGNEMENT_REC_TYPE  |
 |   p_owner_table_name     table using classification  |
 |   p_owner_table_id       id frm that table           |
 |   p_class_category       class_category              |
 |   p_class_code           class code                  |
 |   p_start_date_active    start date of the assignment|
 |   p_end_date_active      end date of the assignment  |
 |   p_primary_flag         primary Y or N              |
 |   p_content_source_type  origin of the assugnment    |
 |   p_status               status                      |
 |   p_created_by_module    creation module             |
 |   p_rank                 for hierarchy assignment    |
 |   p_application_id       application                 |
 |   x_code_assignment_id   OUT assignment id           |
 |   x_return_status        OUT status execution        |
 |   x_msg_count            OUT number of error met     |
 |   x_msg_data             OUT the error message       |
 +------------------------------------------------------*/
PROCEDURE Create_Code_assignment
( p_owner_table_name     IN VARCHAR2,
  p_owner_table_id       IN NUMBER,
  p_class_category       IN VARCHAR2,
  p_class_code           IN VARCHAR2,
  p_start_date_active    IN DATE DEFAULT SYSDATE,
  p_end_date_active      IN DATE,
  p_primary_flag         IN VARCHAR2,
  p_content_source_type  IN VARCHAR2,
  p_status               IN VARCHAR2 DEFAULT 'A',
  p_created_by_module    IN VARCHAR2 DEFAULT 'TCA_FORM_WRAPPER',
  p_rank                 IN VARCHAR2 DEFAULT NULL,
  p_application_id       IN NUMBER   DEFAULT 222,
  x_code_assignment_id   OUT NOCOPY NUMBER,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2 )
IS
  l_code_assignment_rec HZ_CLASSIFICATION_V2PUB.CODE_ASSIGNMENT_REC_TYPE;
  tmp_var                      VARCHAR2(2000);
  i                            NUMBER;
  tmp_var1                     VARCHAR2(2000);
  lexception                   EXCEPTION;
  lyn                          VARCHAR2(1);
BEGIN
  arp_standard.debug('Create_Code_assignment(+)');

  x_return_status  := FND_API.G_RET_STS_SUCCESS;

/*
  -- We allow user to create code assignment prior a start date of another one
  lyn := arh_classification_pkg.assig_after_this_date
           (p_owner_table_name,
            p_owner_table_id,
            p_class_category,
            p_class_code,
            p_start_date_active);

  IF lyn = 'Y' THEN
    FND_MESSAGE.set_name('AR','AR_CLASS_ASS_BEFORE_START_DATE');
    FND_MSG_PUB.ADD;
    RAISE lexception;
  END IF;
*/

  lyn := arh_classification_pkg.exist_overlap_assignment
           (p_owner_table_name,
            p_owner_table_id,
            p_class_category,
            p_class_code,
            p_start_date_active,
            p_end_date_active,
            'INSERT',
            NULL);

  IF lyn = 'Y' THEN
    FND_MESSAGE.set_name('AR','AR_OVERLAP_CLASS_ASS_RECORD');
    FND_MSG_PUB.ADD;
    RAISE lexception;
  END IF;

  l_code_assignment_rec.owner_table_name    := p_owner_table_name;
  l_code_assignment_rec.owner_table_id      := p_owner_table_id;
  l_code_assignment_rec.class_category      := p_class_category;
  l_code_assignment_rec.class_code          := p_class_code;
  l_code_assignment_rec.primary_flag        := p_primary_flag;
  l_code_assignment_rec.content_source_type := p_content_source_type;
  l_code_assignment_rec.start_date_active   := p_start_date_active;
  l_code_assignment_rec.end_date_active     := p_end_date_active;
  l_code_assignment_rec.status              := p_status;
  l_code_assignment_rec.created_by_module   := p_created_by_module;
  l_code_assignment_rec.rank                := p_rank;
  l_code_assignment_rec.application_id      := p_application_id;

-- Now call the stored program
  hz_classification_v2pub.create_code_assignment
  ( p_init_msg_list           => FND_API.G_FALSE,
    p_code_assignment_rec     => l_code_assignment_rec,
    x_return_status           => x_return_status,
    x_msg_count               => x_msg_count,
    x_msg_data                => x_msg_data,
    x_code_assignment_id      => x_code_assignment_id);


    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF x_msg_count > 1 THEN
          FOR i IN 1..x_msg_count  LOOP
             tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
             tmp_var1 := tmp_var1 || ' '|| tmp_var;
          END LOOP;
          x_msg_data := tmp_var1;
       END IF;
       arp_standard.debug(x_msg_data);
    END IF;

  arp_standard.debug('Create_Code_assignment(-)');
EXCEPTION
   WHEN lexception THEN
     x_return_status := fnd_api.g_ret_sts_error;
     FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );
     IF x_msg_count > 1 THEN
        FOR i IN 1..x_msg_count  LOOP
           tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
           tmp_var1 := tmp_var1 || ' '|| tmp_var;
        END LOOP;
        x_msg_data := tmp_var1;
     END IF;
     arp_standard.debug
      ('EXCEPTION lexception: arh_classification_pkg.Create_Code_assignment'||x_msg_data);

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
     FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );
     arp_standard.debug
      ('EXCEPTION: arh_classification_pkg.Create_Code_assignment'||x_msg_data);
END;

/*------------------------------------------------------+
 | Name : Update_Code_assignment                        |
 |                                                      |
 | Description :                                        |
 |  Wrapper on the top TCA V2 API for                   |
 |  Code assignment updation .                          |
 |                                                      |
 | Parameter :                                          |
 |  From the record type                                |
 |   HZ_CLASSIFCIATION_V2PUB.CODE_ASSIGNEMENT_REC_TYPE  |
 |   p_class_category       class_category              |
 |   p_class_code           class code                  |
 |   p_start_date_active    start date of the assignment|
 |   p_end_date_active      end date of the assignment  |
 |   p_primary_flag         primary Y or N              |
 |   p_content_source_type  origin of the assugnment    |
 |   p_status               status                      |
 |   p_rank                 for hierarchy assignment    |
 |   x_object_version_number  record vesrion            |
 |   x_code_assignment_id   OUT assignment id           |
 |   x_return_status        OUT status execution        |
 |   x_msg_count            OUT number of error met     |
 |   x_msg_data             OUT the error message       |
 +------------------------------------------------------*/
PROCEDURE Update_Code_assignment
( p_code_assignment_id    IN NUMBER,
  p_class_category        IN VARCHAR2,
  p_class_code            IN VARCHAR2,
  p_start_date_active     IN DATE,
  p_end_date_active       IN DATE,
  p_content_source_type   IN VARCHAR2,
  p_primary_flag          IN VARCHAR2,
  p_status                IN VARCHAR2,
  p_rank                  IN NUMBER,
  x_object_version_number IN OUT NOCOPY NUMBER,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2 )
IS
  CURSOR cu_code_assig IS
  SELECT ROWID,
         START_DATE_ACTIVE,
         OBJECT_VERSION_NUMBER,
         LAST_UPDATE_DATE
    FROM hz_code_assignments
   WHERE Code_assignment_id  = p_code_assignment_id;
  l_code_assignment_rec HZ_CLASSIFICATION_V2PUB.CODE_ASSIGNMENT_REC_TYPE;
  tmp_var                      VARCHAR2(2000);
  i                            NUMBER;
  tmp_var1                     VARCHAR2(2000);
  l_object_version             NUMBER;
  l_rowid                      ROWID;
  l_last_update_date           DATE;
  l_start_date                 DATE;
  lyn                          VARCHAR2(1);
  l_exception                  EXCEPTION;
  tca_exception                EXCEPTION;
BEGIN
   arp_standard.debug('Update_Code_assignment(+)');
   x_return_status                           := FND_API.G_RET_STS_SUCCESS;

   OPEN cu_code_assig;
   FETCH  cu_code_assig INTO l_rowid,
                             l_start_date,
                             l_object_version,
                             l_last_update_date;
   arp_standard.debug('Last_update_date:'||to_char(l_last_update_date));
   IF cu_code_assig%NOTFOUND THEN
      FND_MESSAGE.SET_NAME('AR','HZ_API_NO_RECORD');
      FND_MESSAGE.SET_TOKEN('RECORD','HZ_CODE_ASSIGNMENT');
      FND_MESSAGE.SET_TOKEN('ID',p_code_assignment_id);
      FND_MSG_PUB.ADD;
      RAISE l_exception;
   ELSE
     IF p_start_date_active <> l_start_date THEN
        FND_MESSAGE.SET_NAME('AR','HZ_API_NONUPDATEABLE_COLUMN');
        FND_MESSAGE.SET_TOKEN('COLUMN','START_DATE_ACTIVE');
        FND_MSG_PUB.ADD;
        RAISE l_exception;
     END IF;
   END IF;
   CLOSE cu_code_assig;


   lyn := arh_classification_pkg.exist_overlap_assignment
           (NULL,
            NULL,
            NULL,
            NULL,
            p_start_date_active,
            p_end_date_active,
            'UPDATE',
            p_code_assignment_id);

   IF lyn = 'Y' THEN
     FND_MESSAGE.set_name('AR','AR_OVERLAP_CLASS_RECORD');
     FND_MSG_PUB.ADD;
     RAISE l_exception;
   END IF;

   l_code_assignment_rec.code_assignment_id  := p_code_assignment_id;
   l_code_assignment_rec.class_category      := p_class_category;
   l_code_assignment_rec.class_code          := p_class_code;
   l_code_assignment_rec.primary_flag        := INIT_SWITCH(p_primary_flag);
   l_code_assignment_rec.content_source_type := INIT_SWITCH(p_content_source_type);
   l_code_assignment_rec.start_date_active   := INIT_SWITCH(p_start_date_active);
   l_code_assignment_rec.end_date_active     := INIT_SWITCH(p_end_date_active);
   l_code_assignment_rec.status              := INIT_SWITCH(p_status);
   l_code_assignment_rec.rank                := INIT_SWITCH(p_rank);
   l_object_version                          := x_object_version_number ;


   hz_classification_v2pub.update_code_assignment(
    p_code_assignment_rec       => l_code_assignment_rec,
    p_object_version_number     => x_object_version_number ,
    x_return_status             => x_return_status,
    x_msg_count                 => x_msg_count,
    x_msg_data                  => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE tca_exception;
    END IF;

    arp_standard.debug('update_code_assignment (-)');
  EXCEPTION
    WHEN l_exception THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_msg_pub.count_and_get(
          p_encoded => fnd_api.g_false,
          p_count => x_msg_count,
          p_data  => x_msg_data);
       IF x_msg_count > 1 THEN
          FOR i IN 1..x_msg_count  LOOP
             tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
             tmp_var1 := tmp_var1 || ' '|| tmp_var;
          END LOOP;
          x_msg_data := tmp_var1;
       END IF;
       arp_standard.debug('Exception arh_classification_pkg.update_code_assignment:'||x_msg_data);

    WHEN tca_Exception THEN
      IF x_msg_count > 1 THEN
          FOR i IN 1..x_msg_count  LOOP
             tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
             tmp_var1 := tmp_var1 || ' '|| tmp_var;
          END LOOP;
          x_msg_data := tmp_var1;
       END IF;
       arp_standard.debug('Exception arh_classification_pkg.update_code_assignment:'||x_msg_data);

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
     FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );
      IF x_msg_count > 1 THEN
          FOR i IN 1..x_msg_count  LOOP
             tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
             tmp_var1 := tmp_var1 || ' '|| tmp_var;
          END LOOP;
          x_msg_data := tmp_var1;
       END IF;
     arp_standard.debug('OTHER Exception arh_classification_pkg.update_code_assignment:'||
                        x_msg_data);

  END;


/*------------------------------------------------------+
 | Name : assig_after_this_date                         |
 |                                                      |
 | Description :                                        |
 |  check if there are any assignment start after a     |
 |  date                                                |
 |                                                      |
 | Parameter :                                          |
 |   p_owner_table_name     table using classification  |
 |   p_owner_table_id       id frm that table           |
 |   p_class_category       class_category              |
 |   p_class_code           class code                  |
 |   p_start_date_active    start date of the assignment|
 | Return  :                                            |
 |  'Y' if there are any                                |
 |  'N' otherwise                                       |
 +------------------------------------------------------*/
FUNCTION assig_after_this_date
 ( p_owner_table_name   IN VARCHAR2 DEFAULT NULL,
   p_owner_table_id     IN NUMBER   DEFAULT NULL,
   p_class_category     IN VARCHAR2 DEFAULT NULL,
   p_class_Code         IN VARCHAR2 DEFAULT NULL,
   p_start_date_active  IN DATE)
 RETURN VARCHAR2
 IS
   CURSOR c IS
   SELECT 'Y'
     FROM hz_code_assignments
    WHERE owner_table_name = p_owner_table_name
      AND owner_table_id   = p_owner_table_id
      AND class_category   = p_class_category
      AND class_code       = p_class_code
      AND start_date_active> p_start_date_active;
  lyn  VARCHAR2(1);
 BEGIN
   OPEN c;
   FETCH c INTO lyn;
   IF c%NOTFOUND THEN
     lyn := 'N';
   END IF;
   CLOSE c;
   RETURN lyn;
 END;


END  arh_classification_pkg;

/
