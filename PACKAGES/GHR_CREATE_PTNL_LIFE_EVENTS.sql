--------------------------------------------------------
--  DDL for Package GHR_CREATE_PTNL_LIFE_EVENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_CREATE_PTNL_LIFE_EVENTS" AUTHID CURRENT_USER AS
/* $Header: ghcrplle.pkh 115.2 2003/07/17 09:25:31 bgarg noship $ */
--
--

PROCEDURE create_ptnl_ler_for_per
(p_pa_request_rec     in ghr_pa_requests%rowtype
);

    PROCEDURE create_ptnl_tsp_ler_for_per
        (p_pa_request_rec     in ghr_pa_requests%rowtype
        );

end ghr_create_ptnl_life_events;


 

/
