--------------------------------------------------------
--  DDL for Package CSTPSCCR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPSCCR" AUTHID CURRENT_USER AS
/* $Header: CSTSCCRS.pls 120.0 2005/05/25 05:56:27 appldev noship $ */

FUNCTION cstrlock (
table_name		IN	VARCHAR2,
l_dest_cost_type_id     IN      NUMBER,
l_default_cost_type_id  IN      NUMBER,
l_rollup_id             IN      NUMBER,
err_buf		      OUT NOCOPY     VARCHAR2,
l_locking_flag          IN      NUMBER := 2
)
RETURN INTEGER;

FUNCTION cstrwait_lock(
l_dest_cost_type_id     IN      NUMBER,
l_default_cost_type_id  IN      NUMBER,
l_rollup_id             IN      NUMBER,
err_buf                 OUT NOCOPY     VARCHAR2,
l_locking_flag          IN      NUMBER := 2
)
RETURN INTEGER;

FUNCTION remove_rolledup_costs(
p_rollup_id             IN      NUMBER,
p_rollup_date           IN      VARCHAR2,
p_buy_cost_type_id      IN      NUMBER,
p_dest_cost_type_id     IN      NUMBER,
p_conc_flag             IN      NUMBER,
req_id                  IN      NUMBER,
prgm_appl_id            IN      NUMBER,
prgm_id                 IN      NUMBER,
x_err_buf               OUT NOCOPY     VARCHAR2,
p_lot_size_option       IN      NUMBER := NULL,  -- SCAPI: dynamic lot size
p_lot_size_setting      IN      NUMBER := NULL,
p_locking_flag          IN      NUMBER := 2  -- Bug 3111820
)
RETURN INTEGER;

FUNCTION cstsccru (
l_rollup_id		       IN	   NUMBER,
req_id                 IN      NUMBER,
l_buy_cost_type_id 	   IN	   NUMBER,
l_dest_cost_type_id    IN	   NUMBER,
l_assignment_set_id	   IN	   NUMBER,
prgm_appl_id           IN      NUMBER,
prgm_id                IN      NUMBER,
l_last_updated_by	   IN	   NUMBER,
conc_flag              IN      NUMBER,
unimp_flag             IN      NUMBER,
locking_flag           IN      NUMBER,
rollup_date            IN      VARCHAR2,
revision_date          IN      VARCHAR2,
alt_bom_designator     IN      VARCHAR2,
alt_rtg_designator     IN      VARCHAR2,
rollup_option		   IN	   NUMBER,
report_option		   IN	   NUMBER,
l_mfg_flag		       IN	   NUMBER,
err_buf			       OUT NOCOPY	   VARCHAR2,
buy_cost_detail        IN      NUMBER := NULL   -- SCAPI: option to perserve buy cost details
)
RETURN INTEGER;

PROCEDURE populate_markup_costs (
l_rollup_id         IN  NUMBER,
l_item_id           IN  NUMBER,
l_org_id            IN  NUMBER,
l_assignment_set_id IN  NUMBER,
l_buy_cost_type_id  IN  NUMBER,
l_dest_cost_type_id IN  NUMBER,
x_err_code          OUT NOCOPY NUMBER,
x_err_buf           OUT NOCOPY VARCHAR2);

PROCEDURE populate_buy_costs (
l_rollup_id         IN  NUMBER,
l_assignment_set_id IN  NUMBER,
l_item_id           IN  NUMBER,
l_org_id            IN  NUMBER,
l_buy_cost_type_id  IN  NUMBER,
x_err_code          OUT NOCOPY NUMBER,
x_err_buf           OUT NOCOPY VARCHAR2);

PROCEDURE populate_shipping_costs (
                            l_rollup_id         IN  NUMBER,
                            l_item_id           IN  NUMBER,
                            l_org_id            IN  NUMBER,
                            l_assignment_set_id IN  NUMBER,
                            l_buy_cost_type_id  IN  NUMBER,
                            l_dest_cost_type_id IN  NUMBER,
                            x_err_code          OUT NOCOPY NUMBER,
                            x_err_buf           OUT NOCOPY VARCHAR2);


FUNCTION process_sc_rollup_op_yields(
				ext_precision  IN NUMBER,
                                l_rollup_id    IN NUMBER,
                                conc_flag      IN NUMBER,
                                req_id         IN NUMBER,
                                prgm_appl_id   IN NUMBER,
                                prgm_id        IN NUMBER,
                                l_last_updated_by IN NUMBER,
                                alt_rtg_designator IN VARCHAR2,
                                rollup_date    IN VARCHAR2,
                                l_organization_id IN NUMBER,
                                l_level        IN NUMBER,
                                l_cost_type_id IN NUMBER,
                                -- Output error message for bug 3097347
                                x_err_buf      OUT NOCOPY VARCHAR2)
return NUMBER;

function supply_chain_snapshot (
l_rollup_id     	in      number,
l_cost_type_id      in      number,
l_mfg_flag      	in      number,
alt_bom_designator  in      varchar2,
l_conc_flag         in      number,
l_unimp_flag        in      number,
revision_date       in      varchar2,
l_last_updated_by   in      number,
l_rollup_date       in      varchar2,
req_id              in      number,
p_prg_appl_id       in      number,
p_prg_id            in      number,
err_buf             out NOCOPY        varchar2)
return integer;

SLEEP_TIME   CONSTANT  number := 10;
NUM_TRIES    CONSTANT  number := 10;


END CSTPSCCR;

 

/
