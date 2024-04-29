--------------------------------------------------------
--  DDL for Package Body QP_PURGE_ENTITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_PURGE_ENTITY" AS
/* $Header: QPXPURGB.pls 120.0 2005/06/02 00:48:06 appldev noship $ */

-- GLOBAL Constant holding the package name

--G_PKG_NAME            CONSTANT        VARCHAR2(30):='QP_PURGE_ENTITY'

/***************************************************************
* Procedure to insert records into the criteria tables *
****************************************************************/

Procedure INSERT_CRITERIA
(
 p_archive_name                       VARCHAR2,
 p_entity_type                        VARCHAR2,
 p_source_system_code                 VARCHAR2,
 p_entity                             NUMBER,
 p_archive_start_date                 VARCHAR2,
 p_archive_end_date                   VARCHAR2,
 p_user_id                            NUMBER,
 p_conc_request_id                    NUMBER,
 p_result_status                      VARCHAR2
)
IS
BEGIN
insert into QP_ARCH_CRITERIA_HEADERS
(request_id,
request_name,
request_type,
source_system,
creation_date,
created_by,
request_status,
purge_flag)
values
(p_conc_request_id,
NULL,
'PURGE',
p_source_system_code,
sysdate,
p_user_id,
p_result_status,
'N');

IF p_archive_name is NULL and p_entity_type is not null and p_entity is not null THEN
insert into QP_ARCH_CRITERIA_LINES
(request_id,
parameter_name,
parameter_value)
values
(p_conc_request_id,
'ENTITY_TYPE',
p_entity_type);

insert into QP_ARCH_CRITERIA_LINES
(request_id,
parameter_name,
parameter_value)
values(p_conc_request_id,
'ENTITY',
p_entity);

END IF;

IF (p_archive_start_date is not null and p_archive_end_date is not null) THEN
insert into QP_ARCH_CRITERIA_LINES
(request_id,
parameter_name,
parameter_value)
values
(p_conc_request_id,
'ARCHIVE_START_DATE',
fnd_date.canonical_to_date(p_archive_start_date));

insert into QP_ARCH_CRITERIA_LINES
(request_id,
parameter_name,
parameter_value)
values(p_conc_request_id,
'ARCHIVE_END_DATE',
fnd_date.canonical_to_date(p_archive_end_date));

END IF;

END INSERT_CRITERIA;


PROCEDURE Purge_Entity
(
 errbuf                 OUT NOCOPY    	VARCHAR2,
 retcode                OUT NOCOPY    	NUMBER,
 p_source_system_code   IN      	VARCHAR2,
 p_archive_name         IN      	VARCHAR2,
 p_entity_type          IN      	VARCHAR2,
 p_entity               IN      	NUMBER,
 p_archive_start_date   IN      	VARCHAR2,
 p_archive_end_date     IN      	VARCHAR2
)
IS
l_conc_request_id			NUMBER := -1;
l_user_id				NUMBER := -1;
l_request_id                  		NUMBER;
l_count                       		NUMBER := 0;

BEGIN

l_conc_request_id := FND_GLOBAL.CONC_REQUEST_ID;
l_user_id         := FND_GLOBAL.USER_ID;

--Check if the archive name is provided

IF p_archive_name is not NULL THEN

BEGIN


-- Get the request id from the archive name

SELECT request_id into l_request_id
FROM QP_ARCH_CRITERIA_HEADERS
WHERE nvl(request_name,'')=p_archive_name
and request_type = 'ARCHIVE'
and purge_flag = 'N';

          EXCEPTION
                WHEN NO_DATA_FOUND THEN
                 RAISE NO_DATA_FOUND;
END;

--Delete from QP_ARCH_LIST_HEADERS_TL

          DELETE QP_ARCH_LIST_HEADERS_TL  WHERE ARCH_PURG_REQUEST_ID  = l_request_id;
          IF SQL%FOUND THEN
             COMMIT;
          END IF;

--Delete from QP_ARCH_LIST_HEADERS_B

          DELETE QP_ARCH_LIST_HEADERS_B  WHERE ARCH_PURG_REQUEST_ID  = l_request_id;
          IF SQL%FOUND THEN
             COMMIT;
          END IF;

--Delete from QP_ARCH_LIST_LINES

          DELETE QP_ARCH_LIST_LINES  WHERE ARCH_PURG_REQUEST_ID  = l_request_id;
          IF SQL%FOUND THEN
             COMMIT;
          END IF;

--Delete from QP_ARCH_PRICING_ATTRIBUTES

          DELETE QP_ARCH_PRICING_ATTRIBUTES  WHERE ARCH_PURG_REQUEST_ID  = l_request_id;
          IF SQL%FOUND THEN
             COMMIT;
          END IF;

--Delete from QP_ARCH_RLTD_MODIFIERS

          DELETE QP_ARCH_RLTD_MODIFIERS  WHERE ARCH_PURG_REQUEST_ID = l_request_id;
          IF SQL%FOUND THEN
             COMMIT;
          END IF;

--Delete from QP_ARCH_QUALIFIERS

          DELETE QP_ARCH_QUALIFIERS  WHERE ARCH_PURG_REQUEST_ID  = l_request_id;
          IF SQL%FOUND THEN
             COMMIT;
          END IF;

--Update the purge_flag in the QP_ARCH_CRITERIA_HEADERS table to Y

           UPDATE QP_ARCH_CRITERIA_HEADERS set PURGE_FLAG = 'Y' where request_id =l_request_id;
           IF SQL%FOUND THEN
             COMMIT;
           END IF;

ELSE -- Archive Name is null

--Check if entity type and entity is provided

IF (p_entity_type is not null and p_entity is not null) THEN
--Get the count of records matching the purge criteria

select count(*) into l_count
from QP_ARCH_CRITERIA_LINES a , QP_ARCH_CRITERIA_LINES b ,QP_ARCH_CRITERIA_HEADERS c
where c.request_id = a.request_id and
a.REQUEST_ID = b.REQUEST_ID
and c.purge_flag = 'N'
and c.REQUEST_TYPE = 'ARCHIVE'
And (a.parameter_name = 'ENTITY_TYPE' and a.parameter_value = p_entity_type)
and (b.parameter_name = 'ENTITY' and b.parameter_value = to_char(p_entity));

	IF l_count = 0 THEN
          RAISE NO_DATA_FOUND;
      	END IF;


--Delete from QP_ARCH_LIST_HEADERS_TL

LOOP
          DELETE QP_ARCH_LIST_HEADERS_TL  WHERE ARCH_PURG_REQUEST_ID  in (select c.request_id from
QP_ARCH_CRITERIA_LINES a , QP_ARCH_CRITERIA_LINES b ,QP_ARCH_CRITERIA_HEADERS c
where c.request_id = a.request_id and
a.REQUEST_ID = b.REQUEST_ID
and c.purge_flag = 'N'
and c.REQUEST_TYPE = 'ARCHIVE'
and (a.parameter_name = 'ENTITY_TYPE' and a.parameter_value = p_entity_type)
and (b.parameter_name = 'ENTITY' and b.parameter_value = to_char(p_entity)))
           AND rownum <= 500;

          IF SQL%NOTFOUND THEN
             EXIT;
          END IF;
          COMMIT;
       END LOOP;

--Delete from QP_ARCH_LIST_HEADERS_B

LOOP
          DELETE QP_ARCH_LIST_HEADERS_B  WHERE ARCH_PURG_REQUEST_ID in (select c.request_id from
QP_ARCH_CRITERIA_LINES a , QP_ARCH_CRITERIA_LINES b ,QP_ARCH_CRITERIA_HEADERS c
where c.request_id = a.request_id and
a.REQUEST_ID = b.REQUEST_ID
and c.purge_flag = 'N'
and c.REQUEST_TYPE = 'ARCHIVE'
and (a.parameter_name = 'ENTITY_TYPE' and a.parameter_value = p_entity_type)
and (b.parameter_name = 'ENTITY' and b.parameter_value = to_char(p_entity)))
           AND rownum <= 500;

          IF SQL%NOTFOUND THEN
             EXIT;
          END IF;
          COMMIT;
       END LOOP;

--Delete from QP_ARCH_LIST_LINES

LOOP
          DELETE QP_ARCH_LIST_LINES  WHERE ARCH_PURG_REQUEST_ID in (select c.request_id from
QP_ARCH_CRITERIA_LINES a , QP_ARCH_CRITERIA_LINES b ,QP_ARCH_CRITERIA_HEADERS c
where c.request_id = a.request_id and
a.REQUEST_ID = b.REQUEST_ID
and c.purge_flag = 'N'
and c.REQUEST_TYPE = 'ARCHIVE'
and (a.parameter_name = 'ENTITY_TYPE' and a.parameter_value = p_entity_type)
and (b.parameter_name = 'ENTITY' and b.parameter_value = to_char(p_entity)))
           AND rownum <= 500;

          IF SQL%NOTFOUND THEN
             EXIT;
          END IF;
          COMMIT;
       END LOOP;

--Delete from QP_ARCH_PRICING_ATTRIBUTES

LOOP
 DELETE QP_ARCH_PRICING_ATTRIBUTES  WHERE ARCH_PURG_REQUEST_ID in (select c.request_id from
QP_ARCH_CRITERIA_LINES a , QP_ARCH_CRITERIA_LINES b ,QP_ARCH_CRITERIA_HEADERS c
where c.request_id = a.request_id and
a.REQUEST_ID = b.REQUEST_ID
and c.purge_flag = 'N'
and c.REQUEST_TYPE = 'ARCHIVE'
and (a.parameter_name = 'ENTITY_TYPE' and a.parameter_value = p_entity_type)
and (b.parameter_name = 'ENTITY' and b.parameter_value = to_char(p_entity)))
           AND rownum <= 500;

          IF SQL%NOTFOUND THEN
             EXIT;
          END IF;
          COMMIT;
       END LOOP;

--Delete from QP_ARCH_RLTD_MODIFIERS

LOOP
DELETE QP_ARCH_RLTD_MODIFIERS  WHERE ARCH_PURG_REQUEST_ID  in
(select c.request_id from
QP_ARCH_CRITERIA_LINES a , QP_ARCH_CRITERIA_LINES b ,QP_ARCH_CRITERIA_HEADERS c
where c.request_id = a.request_id and
a.REQUEST_ID = b.REQUEST_ID
and c.purge_flag = 'N'
and c.REQUEST_TYPE = 'ARCHIVE'
and (a.parameter_name = 'ENTITY_TYPE' and a.parameter_value = p_entity_type)
and (b.parameter_name = 'ENTITY' and b.parameter_value = to_char(p_entity)))
AND rownum <= 500;

          IF SQL%NOTFOUND THEN
             EXIT;
          END IF;
          COMMIT;
       END LOOP;

--Delete from QP_ARCH_QUALIFIERS

LOOP

DELETE QP_ARCH_QUALIFIERS  WHERE ARCH_PURG_REQUEST_ID in
(select c.request_id from
QP_ARCH_CRITERIA_LINES a ,
QP_ARCH_CRITERIA_LINES b ,
QP_ARCH_CRITERIA_HEADERS c
where c.request_id = a.request_id and
a.REQUEST_ID = b.REQUEST_ID
and c.purge_flag = 'N'
and c.REQUEST_TYPE = 'ARCHIVE'
and (a.parameter_name = 'ENTITY_TYPE' and a.parameter_value = p_entity_type)
and (b.parameter_name = 'ENTITY' and b.parameter_value = to_char(p_entity)))
AND rownum <= 500;

          IF SQL%NOTFOUND THEN
             EXIT;

          END IF;
          COMMIT;
       END LOOP;

--Update the purge_flag in the QP_ARCH_CRITERIA_HEADERS table to Y

LOOP
          update QP_ARCH_CRITERIA_HEADERS set PURGE_FLAG = 'Y' WHERE request_id  in (select c.request_id from
QP_ARCH_CRITERIA_LINES a , QP_ARCH_CRITERIA_LINES b ,QP_ARCH_CRITERIA_HEADERS c
where c.request_id = a.request_id and
a.REQUEST_ID = b.REQUEST_ID
and c.purge_flag = 'N'
and c.REQUEST_TYPE = 'ARCHIVE'
and (a.parameter_name = 'ENTITY_TYPE' and a.parameter_value = p_entity_type)
and (b.parameter_name = 'ENTITY' and b.parameter_value = to_char(p_entity)))
           AND rownum <= 500;

          IF SQL%NOTFOUND THEN
             EXIT;
          END IF;
          COMMIT;
       END LOOP;


ELSE --entity_type and entity_id are null

--Check if start date and end date is provided


IF (p_archive_start_date is not null and p_archive_end_date is not null) THEN

--Get the count of records matching the purge criteria

SELECT count(*) into l_count FROM QP_ARCH_CRITERIA_HEADERS
WHERE trunc(creation_date) between trunc(fnd_date.canonical_to_date(p_archive_start_date)) and trunc(fnd_date.canonical_to_date(p_archive_end_date)) and purge_flag = 'N' and REQUEST_TYPE = 'ARCHIVE' and source_system= p_source_system_code;

	IF l_count = 0 THEN
          RAISE NO_DATA_FOUND;
    	END IF;

--Delete from QP_ARCH_LIST_HEADERS_TL

LOOP
          DELETE QP_ARCH_LIST_HEADERS_TL
WHERE ARCH_PURG_REQUEST_ID  in (select request_id from QP_ARCH_CRITERIA_HEADERS
where trunc(creation_date) between  trunc(fnd_date.canonical_to_date(p_archive_start_date))
and trunc(fnd_date.canonical_to_date(p_archive_end_date)) and purge_flag = 'N' and REQUEST_TYPE = 'ARCHIVE' and source_system= p_source_system_code)
           AND rownum <= 500;

          IF SQL%NOTFOUND THEN
             EXIT;
           END IF;
         COMMIT;
       END LOOP;

--Delete from QP_ARCH_LIST_HEADERS_B

LOOP
          DELETE QP_ARCH_LIST_HEADERS_B
WHERE ARCH_PURG_REQUEST_ID in (select request_id from QP_ARCH_CRITERIA_HEADERS
where trunc(creation_date) between  trunc(fnd_date.canonical_to_date(p_archive_start_date))
and trunc(fnd_date.canonical_to_date(p_archive_end_date)) and purge_flag = 'N' and REQUEST_TYPE = 'ARCHIVE' and source_system= p_source_system_code)
           AND rownum <= 500;

          IF SQL%NOTFOUND THEN
             EXIT;
          END IF;
          COMMIT;
       END LOOP;

--Delete from QP_ARCH_LIST_LINES

LOOP
          DELETE QP_ARCH_LIST_LINES
WHERE ARCH_PURG_REQUEST_ID in (select request_id from QP_ARCH_CRITERIA_HEADERS
where trunc(creation_date) between  trunc(fnd_date.canonical_to_date(p_archive_start_date))
and trunc(fnd_date.canonical_to_date(p_archive_end_date)) and purge_flag = 'N' and REQUEST_TYPE = 'ARCHIVE' and source_system= p_source_system_code)
           AND rownum <= 500;

          IF SQL%NOTFOUND THEN
             EXIT;
          END IF;
          COMMIT;
       END LOOP;

--Delete from QP_ARCH_PRICING_ATTRIBUTES

LOOP
          DELETE QP_ARCH_PRICING_ATTRIBUTES
WHERE ARCH_PURG_REQUEST_ID  in (select request_id from QP_ARCH_CRITERIA_HEADERS
where trunc(creation_date) between  trunc(fnd_date.canonical_to_date(p_archive_start_date))
and trunc(fnd_date.canonical_to_date(p_archive_end_date)) and purge_flag = 'N' and REQUEST_TYPE = 'ARCHIVE' and source_system= p_source_system_code)
           AND rownum <= 500;

          IF SQL%NOTFOUND THEN
             EXIT;
          END IF;
          COMMIT;
       END LOOP;

--Delete from QP_ARCH_RLTD_MODIFIERS

LOOP
          DELETE QP_ARCH_RLTD_MODIFIERS
WHERE ARCH_PURG_REQUEST_ID  in (select request_id from QP_ARCH_CRITERIA_HEADERS
where trunc(creation_date) between  trunc(fnd_date.canonical_to_date(p_archive_start_date))
and trunc(fnd_date.canonical_to_date(p_archive_end_date)) and purge_flag = 'N' and REQUEST_TYPE = 'ARCHIVE' and source_system= p_source_system_code)
           AND rownum <= 500;

          IF SQL%NOTFOUND THEN
             EXIT;
          END IF;
          COMMIT;
       END LOOP;

--Delete from QP_ARCH_QUALIFIERS

LOOP
          DELETE QP_ARCH_QUALIFIERS
WHERE ARCH_PURG_REQUEST_ID  in (select request_id from QP_ARCH_CRITERIA_HEADERS
where trunc(creation_date) between  trunc(fnd_date.canonical_to_date(p_archive_start_date))
and trunc(fnd_date.canonical_to_date(p_archive_end_date)) and purge_flag = 'N' and REQUEST_TYPE = 'ARCHIVE' and source_system= p_source_system_code)
           AND rownum <= 500;

         IF SQL%NOTFOUND THEN
             EXIT;
          END IF;
          COMMIT;
       END LOOP;

--Update the purge_flag in the QP_ARCH_CRITERIA_HEADERS table to Y

LOOP
update QP_ARCH_CRITERIA_HEADERS set PURGE_FLAG = 'Y'
WHERE request_id  in (select request_id from QP_ARCH_CRITERIA_HEADERS
where trunc(creation_date) between trunc(fnd_date.canonical_to_date(p_archive_start_date))
and trunc(fnd_date.canonical_to_date(p_archive_end_date)) and purge_flag = 'N' and REQUEST_TYPE = 'ARCHIVE' and source_system= p_source_system_code)
           AND rownum <= 500;

          IF SQL%NOTFOUND THEN
             EXIT;
          END IF;
          COMMIT;
       END LOOP;


END IF; -- Dates
END IF; -- Entity Type and Entity
END IF; -- Archive name.


  commit;

		fnd_file.put_line(FND_FILE.LOG,'Purge completed successfully');

--Call INSERT_CRITERIA to insert records into QP_ARCH_CRITERIA_HEADERS and QP_ARCH_CRITERIA_LINES

  INSERT_CRITERIA(p_archive_name,p_entity_type,p_source_system_code,p_entity,
                  p_archive_start_date,p_archive_end_date,
                  l_user_id,l_conc_request_id,'S');

  errbuf := '';
  retcode := 0;

EXCEPTION
WHEN NO_DATA_FOUND THEN

--Call INSERT_CRITERIA to insert records into QP_ARCH_CRITERIA_HEADERS and QP_ARCH_CRITERIA_LINES

  INSERT_CRITERIA(p_archive_name,p_entity_type,p_source_system_code,p_entity,
                  p_archive_start_date,p_archive_end_date,
                  l_user_id,l_conc_request_id,'W');

            fnd_file.put_line(FND_FILE.LOG,'No Data Found - 0 Records Deleted');
            errbuf := 'No Data Found - 0 Records Deleted';
            retcode := 1;

WHEN OTHERS THEN

--Call INSERT_CRITERIA to insert records into QP_ARCH_CRITERIA_HEADERS and QP_ARCH_CRITERIA_LINES

  INSERT_CRITERIA(p_archive_name,p_entity_type,p_source_system_code,p_entity,
                  p_archive_start_date,p_archive_end_date,
                  l_user_id,l_conc_request_id,'F');

		fnd_file.put_line(FND_FILE.LOG,'Error in Purge Entity Routine ');
                fnd_file.put_line(FND_FILE.LOG,substr(sqlerrm,1,300));
                retcode := 2;

END Purge_entity;

END QP_PURGE_ENTITY;

/
