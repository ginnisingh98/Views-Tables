--------------------------------------------------------
--  DDL for Package GMD_SCALE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_SCALE" AUTHID CURRENT_USER AS
/* $Header: GMDSCALS.pls 115.1 2002/10/25 20:00:52 santunes noship $ */

  TYPE fm_matl_dtl_tab IS TABLE OF fm_matl_dtl%ROWTYPE INDEX BY BINARY_INTEGER;
  TYPE scale_rec IS RECORD
  (  line_no	NUMBER
  ,  line_type  NUMBER
  ,  item_id    NUMBER
  ,  qty        NUMBER
  ,  item_um    VARCHAR2(4)
  ,  scale_type NUMBER
  );
  TYPE scale_tab IS TABLE OF scale_rec;

  PROCEDURE scale
  (  p_scale_tab    IN scale_tab
  ,  p_scale_factor IN NUMBER
  ,  p_primaries          IN VARCHAR2
  ,  x_scale_tab    OUT NOCOPY scale_tab
  ,  x_return_status      OUT NOCOPY VARCHAR2
  );

  PROCEDURE scale
  (  p_fm_matl_dtl_tab    IN fm_matl_dtl_tab
  ,  p_scale_factor       IN NUMBER
  ,  p_primaries          IN VARCHAR2
  ,  x_fm_matl_dtl_tab    OUT NOCOPY fm_matl_dtl_tab
  ,  x_return_status      OUT NOCOPY VARCHAR2
  );
END gmd_scale;

 

/
