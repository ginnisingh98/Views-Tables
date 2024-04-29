--------------------------------------------------------
--  DDL for Package IGI_IAC_XLA_EVENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_XLA_EVENTS_PKG" AUTHID CURRENT_USER as
/* $Header: igixlehs.pls 120.0.12000000.1 2007/10/19 15:17:02 npandya noship $   */


FUNCTION create_revaluation_event
           (p_revaluation_id         IN NUMBER,
            p_event_id               IN OUT NOCOPY NUMBER
           ) return boolean;

FUNCTION update_revaluation_event
           (p_revaluation_id         IN NUMBER) return boolean;


FUNCTION delete_revaluation_event
           (p_revaluation_id         IN NUMBER) return boolean;

END IGI_IAC_XLA_EVENTS_PKG;


 

/
