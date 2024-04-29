--------------------------------------------------------
--  DDL for Package PO_PRICE_DIFFERENTIALS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_PRICE_DIFFERENTIALS_PVT" AUTHID CURRENT_USER AS
/* $Header: POXVPDFS.pls 120.1 2005/08/31 06:58:57 arudas noship $*/

g_pkg_name CONSTANT VARCHAR2(30) := 'PO_PRICE_DIFFERENTIALS_PVT';
FUNCTION  allows_price_differentials
                                  ( p_req_line_id         IN         NUMBER
                                  ) RETURN BOOLEAN;

FUNCTION  check_unique_price_diff_num
                                  ( p_row_id              IN         ROWID
                                  , p_entity_type         IN         VARCHAR2
                                  , p_entity_id           IN         NUMBER
                                  , p_price_differential_num IN      NUMBER
                                  ) RETURN BOOLEAN;

FUNCTION  check_unique_price_type ( p_row_id              IN         ROWID
                                  , p_entity_type         IN         VARCHAR2
                                  , p_entity_id           IN         NUMBER
                                  , p_price_type          IN         VARCHAR2
                                  ) RETURN BOOLEAN;

PROCEDURE copy_price_differentials( p_from_entity_type    IN         VARCHAR2
                                  , p_from_entity_id      IN         NUMBER
                                  , p_to_entity_type      IN         VARCHAR2
                                  , p_to_entity_id        IN         NUMBER
                                  );

PROCEDURE create_from_interface   ( p_entity_id           IN         NUMBER
                                  , p_interface_line_id   IN         NUMBER
                                  );

PROCEDURE default_price_differentials
                                  ( p_from_entity_type    IN         VARCHAR2
                                  , p_from_entity_id      IN         NUMBER
                                  , p_to_entity_type      IN         VARCHAR2
                                  , p_to_entity_id        IN         NUMBER
                                  );

PROCEDURE delete_price_differentials
                                  ( p_entity_type         IN         VARCHAR2
                                  , p_entity_id           IN         VARCHAR2
                                  );

PROCEDURE get_context             ( p_entity_type         IN         VARCHAR2
                                  , p_entity_id           IN         NUMBER
                                  , x_line_num            OUT NOCOPY NUMBER
                                  , x_price_break_num     OUT NOCOPY NUMBER
                                  , x_job_name            OUT NOCOPY VARCHAR2
                                  , x_job_description     OUT NOCOPY VARCHAR2
                                  );

FUNCTION  get_max_price_diff_num  ( p_entity_type         IN         VARCHAR2
                                  , p_entity_id           IN         NUMBER
                                  ) RETURN NUMBER;

PROCEDURE get_min_max_multiplier  ( p_entity_type         IN         VARCHAR2
                                  , p_entity_id           IN         NUMBER
                                  , p_price_type          IN         VARCHAR2
                                  , x_min_multiplier      OUT NOCOPY NUMBER
                                  , x_max_multiplier      OUT NOCOPY NUMBER
                                  );

FUNCTION  has_price_differentials ( p_entity_type         IN         VARCHAR2
                                  , p_entity_id           IN         NUMBER
                                  ) RETURN BOOLEAN;

FUNCTION  is_price_type_enabled   ( p_price_type          IN         VARCHAR2
                                  , p_entity_type         IN         VARCHAR2
                                  , p_entity_id           IN         NUMBER
                                  ) RETURN BOOLEAN;

PROCEDURE setup_interface_table   ( p_entity_type         IN         VARCHAR2
                                  , p_interface_header_id IN         NUMBER
                                  , p_interface_line_id   IN         NUMBER
                                  , p_req_line_id         IN         NUMBER
                                  , p_from_line_id        IN         NUMBER
                                  , p_price_break_id      IN         NUMBER
                                  );

PROCEDURE validate_price_differentials(
                      p_interface_header_id      IN NUMBER,
                      p_interface_line_id        IN NUMBER,
                      p_entity_type              IN VARCHAR2,
                      p_entity_id                IN NUMBER,
                      p_header_processable_flag  IN VARCHAR2
);

PROCEDURE get_price_for_price_type
(
    p_entity_id           IN         NUMBER
,   p_entity_type         IN         VARCHAR2
,   p_price_type          IN         VARCHAR2
,   x_price               OUT NOCOPY NUMBER
);

--<HTML Agreements R12 Start>
FUNCTION get_entity_type( p_doc_level   IN VARCHAR2
                         ,p_doc_level_id IN NUMBER)
RETURN VARCHAR2;
--<HTML Agreements R12 End>
END PO_PRICE_DIFFERENTIALS_PVT;

 

/
