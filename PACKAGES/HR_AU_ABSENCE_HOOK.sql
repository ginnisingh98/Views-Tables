--------------------------------------------------------
--  DDL for Package HR_AU_ABSENCE_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_AU_ABSENCE_HOOK" AUTHID CURRENT_USER AS
/* $Header: peaulhab.pkh 120.2 2006/03/23 15:39:51 strussel noship $ */

 PROCEDURE UPDATE_ABSENCE_DEV_DESC_FLEX  (p_absence_attendance_id IN   NUMBER
                               );

END hr_au_absence_hook ;

 

/
