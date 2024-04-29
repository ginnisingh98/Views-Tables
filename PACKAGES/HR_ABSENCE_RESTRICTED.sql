--------------------------------------------------------
--  DDL for Package HR_ABSENCE_RESTRICTED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ABSENCE_RESTRICTED" AUTHID CURRENT_USER as
/* $Header: peabrest.pkh 120.0.12010000.2 2010/03/08 09:36:49 ghshanka noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< absences_restricted >--------------------------|
-- ----------------------------------------------------------------------------
--
function absences_restricted
   (selected_person_id in varchar2,
   login_person_id in varchar2)
return varchar2;

--
end;

/
