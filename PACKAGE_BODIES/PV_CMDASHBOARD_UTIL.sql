--------------------------------------------------------
--  DDL for Package Body PV_CMDASHBOARD_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_CMDASHBOARD_UTIL" AS
/* $Header: pvxvcdub.pls 120.3 2005/09/12 05:32:57 appldev noship $ */

PROCEDURE get_kpis_detail (
 p_resource_id  IN NUMBER,
 p_kpi_set  IN OUT NOCOPY kpi_tbl_type )
 IS

 -- Cursor to select all attrbutes details.
   CURSOR l_sql_text_csr(cv_attribute_id  NUMBER) IS
	SELECT pav.name name, pav.return_type return_type, pav.display_style display_style,
	       pea.sql_text sql_text, pav.enabled_flag enabled_flag
	FROM pv_entity_attrs pea,
	     pv_attributes_vl pav
	WHERE entity = 'PARTNER_GROUP_KPI'
	AND pea.attribute_id = pav.attribute_id
	AND pav.attribute_id = cv_attribute_id
	AND pav.enabled_flag = 'Y';

   l_sql_stmt		VARCHAR2(4000);
   l_attr_name		VARCHAR2(60);
   l_return_type	VARCHAR2(30);
   l_display_style	VARCHAR2(30);
   l_currency		VARCHAR2(30);
   l_value              NUMBER;
   l_attribute_id	NUMBER;
   l_resource_id	NUMBER := p_resource_id;
   l_enabled_flag       VARCHAR2(1);
   rec_index		NUMBER;

 BEGIN

  l_currency := FND_PROFILE.value('ICX_PREFERRED_CURRENCY');

  FOR rec_index IN p_kpi_set.first..p_kpi_set.last
  LOOP

     l_attribute_id := p_kpi_set(rec_index).attribute_id;

     -- Get the SQL statement for the given attribute_id.

     OPEN l_sql_text_csr(l_attribute_id );
     FETCH l_sql_text_csr INTO l_attr_name, l_return_type, l_display_style, l_sql_stmt, l_enabled_flag;

     -- Initialize the common out variables for each attribute.
     p_kpi_set(rec_index).attribute_id := l_attribute_id ;
     p_kpi_set(rec_index).attribute_name := l_attr_name ;

     IF ( l_sql_text_csr%FOUND) THEN

        BEGIN
	   IF (l_return_type = 'CURRENCY' ) THEN

	       EXECUTE IMMEDIATE l_sql_stmt
		    INTO l_value
		    USING l_currency, l_attribute_id, l_resource_id;

	    ELSIF (l_return_type = 'NUMBER') THEN

	       EXECUTE IMMEDIATE l_sql_stmt
		    INTO l_value
		    USING l_attribute_id, l_resource_id;

	    END IF;

            IF l_value is NULL THEN
               l_value := 0;
            END IF;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               l_value := 0;
            WHEN OTHERS THEN
               l_value := null;
         END;

	-- Initialize the out variables for each attribute.
        p_kpi_set(rec_index).attribute_value := l_value ;
        p_kpi_set(rec_index).enabled_flag := l_enabled_flag ;
        p_kpi_set(rec_index).display_style := l_display_style ;

     ELSIF (l_sql_text_csr%NOTFOUND) THEN

	-- Initialize the out variables for each attribute.

        p_kpi_set(rec_index).attribute_value := null ;
        p_kpi_set(rec_index).enabled_flag := 'N' ;
        p_kpi_set(rec_index).display_style := null ;

     END IF;

     -- Close the cursor l_sql_text_csr
     CLOSE l_sql_text_csr;

  END LOOP;

 END get_kpis_detail ;

END PV_CMDASHBOARD_UTIL;

/
