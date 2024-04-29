--------------------------------------------------------
--  DDL for Package PERCOMPSTATUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PERCOMPSTATUS" AUTHID CURRENT_USER AS
/* $Header: hrcpstats.pkh 120.0 2005/05/31 23:56:09 appldev noship $*/
g_date_format constant varchar2(15) := 'RRRR-MM-DD';
FUNCTION Get_Competence_Status
    (p_competence_id          in varchar2
    ,p_competence_element_id  in varchar2
    ,p_item_type               IN VARCHAR2 DEFAULT null
    ,p_item_key                IN VARCHAR2 DEFAULT null
    ,p_activity_id             IN VARCHAR2 DEFAULT null
    ,p_eff_date               in date default trunc(sysdate)
    ) Return varchar2;

FUNCTION Get_Competence_Status
    (p_item_type       in varchar2
    ,p_item_key        IN varchar2
    ,p_activity_id     IN varchar2
    ,p_competence_id   in number
    ,p_competence_element_id IN NUMBER DEFAULT null
    ,p_person_id             IN number
    ,p_eff_date                in date default trunc(sysdate)
    ) return VARCHAR2;


function get_status_meaning_and_id
    (p_competence_id         in varchar2
    ,p_competence_element_id in varchar2
    ,p_item_type               IN VARCHAR2 DEFAULT null
    ,p_item_key                IN VARCHAR2 DEFAULT null
    ,p_activity_id             IN VARCHAR2 DEFAULT null
    ,p_eff_date              in date default trunc(sysdate))
    RETURN varchar2;

Function IsAllCompAchieved
     ( p_qualification_type_id IN number
     , p_person_id             IN number)
     RETURN varchar2;

END PerCompStatus;

 

/
