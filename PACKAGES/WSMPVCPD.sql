--------------------------------------------------------
--  DDL for Package WSMPVCPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSMPVCPD" AUTHID CURRENT_USER AS
/* $Header: WSMVCPDS.pls 115.4 2002/11/14 23:22:47 zchen ship $ */


/*===========================================================================
  PROCEDURE NAME:       val_co_prduct_related

  DESCRIPTION:          This routine is used to verify if a bill has
                        one or more currently active components with an active
                        co-product relationship.

  PARAMETERS:           x_bill_sequence_id IN       NUMBER,
                        x_result           IN OUT NOCOPY   VARCHAR2,
                        x_error_code       IN OUT NOCOPY   NUMBER,
                        x_error_msg        IN OUT NOCOPY   VARCHAR2

                        x_result     :  Y, N
                        x_error_code :  0 - Successful.
                                        Other values - SQL Error.

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       Ramana Mulpury        03/06/98   Created
===========================================================================*/
PROCEDURE val_co_product_related (x_bill_sequence_id IN     NUMBER,
                                  x_result           IN OUT NOCOPY VARCHAR2,
                                  x_error_code       IN OUT NOCOPY NUMBER,
                                  x_error_msg        IN OUT NOCOPY VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:       val_co_product

  DESCRIPTION:          This routine is used to perform the following
                        validation.

                            - The co-product is unique for a
                              component/effectivity/organization combination.
                            - The substitutes that exist for the
                              component are not the same as the co-product.

  PARAMETERS:           x_rowid                 IN      VARCHAR2
                        x_co_product_group_id   IN      NUMBER
                        x_co_product_id         IN      NUMBER
                        x_error_code            IN OUT NOCOPY  NUMBER
                        x_error_msg             IN OUT NOCOPY  VARCHAR2

                        x_error_code :  0 - Successful.
                                        1 - In sufficient arguments.
                                        2 - Business validation failure.
                                        Other values - SQL Error.

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       Ramana Mulpury        06/16/97   Created
===========================================================================*/
PROCEDURE val_co_product (x_rowid               IN     VARCHAR2,
                          x_co_product_group_id IN     NUMBER,
                          x_co_product_id       IN     NUMBER,
                          x_error_code          IN OUT NOCOPY NUMBER,
                          x_error_msg           IN OUT NOCOPY VARCHAR2);


/*===========================================================================
  PROCEDURE NAME:       val_substitute_coproduct

  DESCRIPTION:          This routine is used to perform the following
                        validation of the substitute co-product.

  PARAMETERS:

                        x_error_code :  0   - Successful.
                                        > 0 - Business validation failure.
                                        Other values - SQL Error.

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       Ramana Mulpury        01/27/98   Created
===========================================================================*/
PROCEDURE val_substitute_coproduct(x_substitute_co_product_id   IN     NUMBER,
                                   x_co_product_group_id        IN     NUMBER,
                                   x_co_product_id              IN     NUMBER,
                                   x_error_code                 IN OUT NOCOPY NUMBER,
                                   x_error_msg                  IN OUT NOCOPY VARCHAR2);


/*===========================================================================
  PROCEDURE NAME:       val_pre_commit

  DESCRIPTION:          This routine is a cover for the routines that
                        are called in order to perform pre-commit validation
                        on the server.

  PARAMETERS:           x_co_product_group_id   IN      NUMBER
                        x_error_code            IN OUT NOCOPY  NUMBER
                        x_error_msg             IN OUT NOCOPY  VARCHAR2

                        x_error_code :  0 - Successful.
                                        2 - Business validation failure.
                                        Other values - SQL Error.

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       Ramana Mulpury        06/21/97   Created
===========================================================================*/
PROCEDURE val_pre_commit (x_co_product_group_id IN     NUMBER,
                          x_error_code          IN OUT NOCOPY NUMBER,
                          x_error_msg           IN OUT NOCOPY VARCHAR2);



/*===========================================================================
  PROCEDURE NAME:       val_primary_flag

  DESCRIPTION:          This routine validates that there is one and
                        only one primary co-product for a component.

  PARAMETERS:           x_rowid                 IN      VARCHAR2
                        x_co_product_group_id   IN      NUMBER
                        x_error_code            IN OUT NOCOPY  NUMBER
                        x_error_msg             IN OUT NOCOPY  VARCHAR2

                        x_error_code :  0 - Successful.
                                        1 - In sufficient arguments.
                                        2 - Business validation failure.
                                        Other values - SQL Error.

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       Ramana Mulpury        06/16/97   Created
===========================================================================*/
PROCEDURE val_primary_flag (x_co_product_group_id IN     NUMBER,
                            x_error_code          IN OUT NOCOPY NUMBER,
                            x_error_msg           IN OUT NOCOPY VARCHAR2);


/*===========================================================================
  PROCEDURE NAME:       val_split_total

  DESCRIPTION:          This routine validates that the split percentage
                        of all co-products for a component adds up to
                        100.

  PARAMETERS:           x_co_product_group_id   IN      NUMBER
                        x_error_code            IN OUT NOCOPY  NUMBER
                        x_error_msg             IN OUT NOCOPY  VARCHAR2

                        x_error_code :  0 - Successful.
                                        1 - In sufficient arguments.
                                        2 - Business validation failure.
                                        Other values - SQL Error.

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       Ramana Mulpury        06/16/97   Created
===========================================================================*/
PROCEDURE val_split_total (x_co_product_group_id IN     NUMBER,
                           x_error_code          IN OUT NOCOPY NUMBER,
                           x_error_msg           IN OUT NOCOPY VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:       val_add_to_bill

  DESCRIPTION:          This routine performs the processing
                        required to verify if components can be
                        added to an existing bill.

  PARAMETERS:               x_co_product_group_id        IN     NUMBER,
                            x_org_id                     IN     NUMBER,
                            x_co_product_id              IN     NUMBER,
                            x_comm_bill_sequence_id      IN     NUMBER,
                            x_curr_bill_sequence_id      IN     NUMBER,
                            x_effectivity_date           IN     DATE,
                            x_disable_date               IN     DATE,
                            x_alternate_designator       IN     VARCHAR2,
                            x_error_code                 IN OUT NOCOPY NUMBER,
                            x_error_msg                  IN OUT NOCOPY VARCHAR

                        x_error_code :  0 - Successful.
                        x_error_code :  3 - Validation error.
                        Other values:    - SQL Error.

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       Ramana Mulpury        07/11/97   Created
===========================================================================*/
PROCEDURE val_add_to_bill ( x_co_product_group_id        IN     NUMBER,
                            x_org_id                     IN     NUMBER,
                            x_co_product_id              IN     NUMBER,
                            x_comm_bill_sequence_id      IN     NUMBER,
                            x_curr_bill_sequence_id      IN     NUMBER,
                            x_effectivity_date           IN     DATE,
                            x_disable_date               IN     DATE,
                            x_alternate_designator       IN     VARCHAR2,
                            x_error_code                 IN OUT NOCOPY NUMBER,
                            x_error_msg                  IN OUT NOCOPY VARCHAR2);


/*===========================================================================
  PROCEDURE NAME:       val_component_overlap

  DESCRIPTION:          This routine is used to perform the following
                        validation.

                            - The component is unique for a
                              component/effectivity/organization combination.

  PARAMETERS:           x_org_id        IN     NUMBER,
                        x_component_id  IN     NUMBER,
                        x_effectivity_date IN  DATE,
                        x_disable_date     IN  DATE,
                        x_rowid            IN  VARCHAR2,
                        x_error_code     IN OUT NOCOPY NUMBER,
                        x_error_msg      IN OUT NOCOPY VARCHAR2

                        x_error_code :  0 - Successful.
                                        Other values - SQL Error.

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       Ramana Mulpury        06/20/97   Created
===========================================================================*/
PROCEDURE val_component_overlap  (x_org_id        IN     NUMBER,
                                  x_component_id  IN     NUMBER,
                                  x_effectivity_date IN  DATE,
                                  x_disable_date  IN     DATE,
                                  x_rowid         IN     VARCHAR2,
                                  x_error_code    IN OUT NOCOPY NUMBER,
                                  x_error_msg     IN OUT NOCOPY VARCHAR2);


END;

 

/
