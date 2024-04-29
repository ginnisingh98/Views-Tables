--------------------------------------------------------
--  DDL for Package PER_AU_ASG_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_AU_ASG_LEG_HOOK" AUTHID CURRENT_USER AS
/* $Header: peaulhas.pkh 120.0 2005/09/20 11:12:12 abhargav noship $ */

 PROCEDURE UPDATE_AU_ASG      (p_assignment_id     	IN   NUMBER
                               ,p_effective_date    		IN   DATE
                                ,p_segment1          		IN  VARCHAR2
                               );

END PER_AU_ASG_LEG_HOOK ;

 

/
