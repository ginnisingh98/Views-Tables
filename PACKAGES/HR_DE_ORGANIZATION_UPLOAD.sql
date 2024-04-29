--------------------------------------------------------
--  DDL for Package HR_DE_ORGANIZATION_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DE_ORGANIZATION_UPLOAD" AUTHID CURRENT_USER AS
 /* $Header: pedeoupl.pkh 115.2 2002/11/26 16:32:55 jahobbs noship $ */
 --
 --
 -- --------------------------------------------------------------------------
 -- This uploads the definitions for tax offices as organizations in the HRMS
 -- system.
 --
 -- The definitions for the tax offices are held in a user table named
 -- HR_DE_TAX_OFFICE_DEFINITION which can be seen by using a view named
 -- HR_DE_TAX_DEFINITION_V.
 --
 -- The parameters are defined as follows...
 --
 -- p_business_group_id: the business group for which this upload is being run.
 -- p_effective_date   : the date on which the changes are made.
 -- p_upload_mode      : the mode is either 'Merge' or 'Analyse' (see below for
 --                      details).
 -- p_bundesland       : can be used to identify a subset of the tax offices
 --                      NB. leaving this blank means load all tax offices.
 --
 -- The mode of 'Merge' only adds tax offices that do not already exist, while
 -- 'Analyse' produces a summary of what would happen if 'Merge' was used.
 -- --------------------------------------------------------------------------
 --
 PROCEDURE upload_tax_offices
 (errbuf              OUT NOCOPY VARCHAR2
 ,retcode             OUT NOCOPY NUMBER
 ,p_business_group_id     NUMBER
 ,p_effective_date        VARCHAR2
 ,p_upload_mode           VARCHAR2
 ,p_bundesland            VARCHAR2);
 --
 --
 -- --------------------------------------------------------------------------
 -- This uploads the definitions for social insurance providers as organizations
 -- in the HRMS system.
 --
 -- The definitions for the social insurance providers are held in a user table
 -- named HR_DE_SOC_INS_PROV_DEFINITION which can be seen by using a view named
 -- HR_DE_SOCINS_PROV_DEFINITION_V.
 --
 -- The parameters are defined as follows...
 --
 -- p_business_group_id: the business group for which this upload is being run.
 -- p_effective_date   : the date on which the changes are made.
 -- p_upload_mode      : the mode is either 'Merge' or 'Analyse' (see below for
 --                      details).
 -- p_provider_type    : can be used to identify a subset of the social insurance
 --                      providers e.g. mandatory health providers, mandatory
 --                      pension providers, etc.
 --
 -- The mode of 'Merge' only adds social insurance providers that do not already
 -- exist, while 'Analyse' produces a summary of what would happen if 'Merge'
 -- was used.
 -- --------------------------------------------------------------------------
 --
 PROCEDURE upload_soc_ins_providers
 (errbuf              OUT NOCOPY VARCHAR2
 ,retcode             OUT NOCOPY NUMBER
 ,p_business_group_id     NUMBER
 ,p_effective_date        VARCHAR2
 ,p_upload_mode           VARCHAR2
 ,p_provider_type         VARCHAR2);
END hr_de_organization_upload;

 

/
