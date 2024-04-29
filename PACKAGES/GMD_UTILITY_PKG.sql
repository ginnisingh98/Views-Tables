--------------------------------------------------------
--  DDL for Package GMD_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_UTILITY_PKG" AUTHID CURRENT_USER AS
/* $Header: GMDUTLPS.pls 115.2 2002/11/15 16:32:29 cnagarba noship $ */
TYPE exprec is RECORD
     (poperand        VARCHAR2(100),
      pvalue         NUMBER,
      pvalue_type     VARCHAR2(1));


  TYPE exptab IS TABLE OF exprec INDEX BY BINARY_INTEGER;


  PROCEDURE parse (x_exp             IN   VARCHAR2,
                   x_exptab          OUT NOCOPY  exptab,
                   x_return_status   OUT NOCOPY  VARCHAR2);

  PROCEDURE variable_value(pvar_name   IN      VARCHAR2,
                           pvar_value  IN      NUMBER,
                           p_exptab    IN OUT NOCOPY  exptab,
                           x_return_status OUT NOCOPY VARCHAR2);

  PROCEDURE evaluate_exp(pexptab         IN exptab,
                         pexp_test       IN BOOLEAN DEFAULT FALSE,
                         x_value         OUT NOCOPY NUMBER,
                         x_return_status OUT NOCOPY  VARCHAR2);

  PROCEDURE tokenize_exp(pexp    IN  VARCHAR2,
                         x_exptab OUT NOCOPY exptab);



  PROCEDURE execute_exp(pexp        IN  VARCHAR2,
                        pexp_test   IN  BOOLEAN DEFAULT FALSE,
                        x_result    OUT NOCOPY NUMBER,
                        x_return_status OUT NOCOPY VARCHAR2);


 END GMD_UTILITY_PKG;


 

/
