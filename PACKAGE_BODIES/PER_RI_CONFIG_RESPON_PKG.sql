--------------------------------------------------------
--  DDL for Package Body PER_RI_CONFIG_RESPON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RI_CONFIG_RESPON_PKG" as
/* $Header: perriconresp.pkb 120.0 2005/06/01 01:02:05 appldev noship $ */
PROCEDURE create_config_responsibility(p_responsibility_application IN VARCHAR2
	                              ,p_territory_code             IN VARCHAR2
	                              ,p_responsibility_key         IN VARCHAR2
	                               )
IS

        l_resp_app	PER_RI_CONFIG_RESPONSIBILITY.RESPONSIBILITY_APPLICATION%TYPE;
	-- Cursor to check the
	CURSOR csr_cnf_resp IS
	    SELECT lookup_code
	        FROM  hr_lookups
	        WHERE lookup_type  = 'PER_RI_CONFIG_PRODUCTS'
		AND   lookup_code in (select responsibility_application
				      from per_Ri_config_responsibility
				      where responsibility_application like p_responsibility_application
				      and territory_code like p_territory_code
				      and responsibility_key like p_responsibility_key);

BEGIN


	OPEN csr_cnf_resp;
	FETCH csr_cnf_resp INTO l_resp_app;

	IF csr_cnf_resp%NOTFOUND THEN
		INSERT INTO PER_RI_CONFIG_RESPONSIBILITY (responsibility_application,territory_code,responsibility_key)
		VALUES  (p_responsibility_application,p_territory_code,p_responsibility_key);
	ELSE
		return;

	END IF;

END create_config_responsibility;

PROCEDURE load_configuration( p_responsibility_application  IN  VARCHAR2
                             ,p_territory_code              IN  VARCHAR2
                             ,p_responsibility_key          IN  VARCHAR2
                             )
IS
	l_resp_app	PER_RI_CONFIG_RESPONSIBILITY.RESPONSIBILITY_APPLICATION%TYPE;

	-- Check if config respy already exists
	 CURSOR csr_cnf_resp IS
	     SELECT responsibility_application
	     FROM   per_ri_config_responsibility
             WHERE  responsibility_application = p_responsibility_application
             AND    territory_code             = p_territory_code
             AND    responsibility_key         = p_responsibility_key;

BEGIN

 	OPEN csr_cnf_resp;
   	FETCH csr_cnf_resp INTO l_resp_app;

   	IF csr_cnf_resp%NOTFOUND THEN

	create_config_responsibility(p_responsibility_application => p_responsibility_application
	                            ,p_territory_code             => p_territory_code
	                            ,p_responsibility_key         => p_responsibility_key
	                            );

	END IF;

	-- As all are key columns, there will ideally be no need for an update
	/*update_config_responsibility(p_responsibility_application => p_responsibility_application
	                            ,p_territory_code             => p_territory_code
	                            ,p_responsibility_key         => p_responsibility_key
	                            );
   	END IF;*/

END load_configuration;


END per_ri_config_respon_pkg;



/
