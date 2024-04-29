--------------------------------------------------------
--  DDL for Package HXC_SEEDDATA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_SEEDDATA_PKG" AUTHID CURRENT_USER AS
/* $Header: hxcseeddatapkg.pkh 120.1 2005/06/28 23:44:26 dragarwa noship $ */



  TYPE r_rec is RECORD (
     object_id              NUMBER (15),
     object_type            VARCHAR2 (80),
     owner_application_id   NUMBER (15),
     VALUE                  VARCHAR2 (150),
     application_name       VARCHAR2 (240),
     code_level_required    VARCHAR2 (80),
     HXC_REQUIRED           VARCHAR2(30),
     created_by             NUMBER(15),
     creation_date          DATE,
     last_updated_by        number(15),
     last_update_date       date,
     last_update_login      number(15)
     );

   TYPE t_rec IS TABLE OF r_rec INDEX BY BINARY_INTEGER;


   -- The get_query function just returns the query as a string. The query depends on
   -- the object_type passed.

   FUNCTION get_query(p_object_type in varchar2)
   RETURN VARCHAR2;


   --The get_value function takes the object type and finds the query using get_query.
   --It then makes use of p_object_id to find the value corresponding to the object_id
   --This function is used by hxcseed.lct loader for its download section

   FUNCTION get_value ( p_object_id in number,
                        p_object_type in varchar2 )
   RETURN varchar2;


   --The get_legislation_code function returns the legislation code based on the
   --object_id and object_type. This function is also used by hxcseed.lct lader for its
   --download section

   FUNCTION get_legislation_code(p_object_id in number,
                        p_object_type in varchar2 )
   RETURN varchar2;


   --The HXC_SEEDDATA_BY_LEVEL block of the HXCSEEDDATA form is based on
   --the stored procedure hxc_seeddata_by_level_query.

   PROCEDURE hxc_seeddata_by_level_query
       (p_seeddata_by_level_data in out NOCOPY t_rec,
        p_object_type in varchar2,
        p_value in varchar2,
        p_application_name in varchar2,
        p_code_level_required in varchar2,
        p_count out NOCOPY number);


END HXC_SEEDDATA_PKG;

 

/
