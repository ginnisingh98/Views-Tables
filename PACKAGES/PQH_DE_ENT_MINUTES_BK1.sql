--------------------------------------------------------
--  DDL for Package PQH_DE_ENT_MINUTES_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_ENT_MINUTES_BK1" AUTHID CURRENT_USER as
/* $Header: pqetmapi.pkh 120.0 2005/05/29 01:52:19 appldev noship $ */

  Procedure Insert_ENT_MINUTES_b
  (p_effective_date                     in  date
  ,p_TARIFF_Group_CD                    In  Varchar2
  ,p_ent_minutes_CD                      In  Varchar2
  ,P_DESCRIPTION                        In  Varchar2
  ,P_ENT_MINUTES_ID		        IN  Number
  ,p_business_group_id                  in  number    ) ;

--
-- ----------------------------------------------------------------------------
-- |-------------------------< <Insert_ENT_MINUTES_a> >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure Insert_ENT_MINUTES_a
  (p_effective_date                     in  date
  ,p_TARIFF_Group_CD                    In  Varchar2
  ,p_ent_minutes_CD                      In  Varchar2
  ,P_DESCRIPTION                        In  Varchar2
  ,P_ENT_MINUTES_ID		        IN  Number
  ,p_business_group_id                  in  number    ) ;

 --
end PQH_DE_ENT_MINUTES_BK1;

 

/
