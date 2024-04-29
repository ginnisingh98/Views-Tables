--------------------------------------------------------
--  DDL for Package GMD_GME_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_GME_INT" AUTHID CURRENT_USER AS
/* $Header: GMDGMEIS.pls 120.2.12010000.1 2008/07/24 09:54:07 appldev ship $ */


PROCEDURE check_qc(
      p_recipeid        IN NUMBER,
      p_routingid       IN NUMBER,
      p_routingstepid   IN NUMBER,
      p_organization_id IN NUMBER DEFAULT NULL,
      p_resultout       OUT NOCOPY VARCHAR2);


END GMD_GME_INT ;


/
