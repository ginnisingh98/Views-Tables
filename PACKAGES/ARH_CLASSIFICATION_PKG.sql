--------------------------------------------------------
--  DDL for Package ARH_CLASSIFICATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARH_CLASSIFICATION_PKG" AUTHID CURRENT_USER AS
/*$Header: ARCLAASS.pls 115.2 2002/12/30 18:20:59 hyu noship $*/

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
  x_msg_data             OUT NOCOPY VARCHAR2 );

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
  x_msg_data              OUT NOCOPY VARCHAR2 );

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
RETURN VARCHAR2;

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
RETURN VARCHAR2;

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
RETURN VARCHAR2;


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
 RETURN VARCHAR2;


/*------------------------------------------------------+
 | Name : is_overlap                                    |
 |                                                      |
 | Description :                                        |
 |  check if period (s1 e1) overlaps (s2 e2)            |
 |  exclusive or inclusively                            |
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
RETURN VARCHAR2;

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
RETURN VARCHAR2;

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
RETURN VARCHAR2;

END;

 

/
