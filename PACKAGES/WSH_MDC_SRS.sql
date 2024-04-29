--------------------------------------------------------
--  DDL for Package WSH_MDC_SRS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_MDC_SRS" AUTHID CURRENT_USER AS
/* $Header: WSHMDSRS.pls 120.3 2005/09/02 01:47:02 agbennet noship $ */

--===================
-- PUBLIC VARIABLES
--===================

--========================================================================
-- TYPE : addnl_del_attr_rec_type
--
-- COMMENT   : The delivery details are stored in two parallel tables.
--             The generic information is stored using the type
--             WSH_FTE_CONSTRAINT_FRAMEWORK.delivery_ccinfo_tab_type.
--             All the additional details are stored using the record
--             described below.
--========================================================================

TYPE addnl_del_attr_rec_type IS RECORD(
    delivery_id         NUMBER,
    fob_code            VARCHAR2(30),
    freight_terms_code  VARCHAR2(30),
    loading_sequence    NUMBER,
    gross_weight        NUMBER,
    weight_uom_code     VARCHAR2(3),
    ignore_for_planning VARCHAR2(1),
    ship_to_country     VARCHAR2(120),
    ship_to_state       VARCHAR2(120),
    ship_to_city        VARCHAR2(120),
    ship_to_postal_code VARCHAR2(60),
    consol_index          NUMBER,
    intermediate_pickup_date    DATE,
    deconsol_trip_id    NUMBER,
    deconsol_trip_name  VARCHAR2(30),
    group_id            NUMBER,
    hash_value          NUMBER,
    hash_string         VARCHAR2(1000)
);


--========================================================================
-- TYPE : addnl_del_attr_tab_type
--
-- COMMENT   : The table stores the additional information regarding
--             deliveries.
--========================================================================
TYPE addnl_del_attr_tab_type IS TABLE OF addnl_del_attr_rec_type INDEX BY binary_integer;


--========================================================================
-- TYPE : grp_attr_rec_type
--
-- COMMENT   : Record type to store the consolidation groupings created
--             along with the deliveries going beonging to the group.
--========================================================================
TYPE grp_attr_rec_type IS RECORD(
    group_id        NUMBER,
    delivery_list   wsh_util_core.id_tab_type,
    hash_value      NUMBER,
    hash_string     VARCHAR2(1000)
);


--========================================================================
-- TYPE : grp_attr_tab_type
--
-- COMMENT   : Table holding the groups for consolidaiton.
--========================================================================
TYPE grp_attr_tab_type IS TABLE OF grp_attr_rec_type INDEX BY binary_integer;


--========================================================================
-- TYPE : group_by_flags_rec_type
--
-- COMMENT   : Record containing the grouping attributes specified in the
--             consolidation grouping rule.
--========================================================================
TYPE group_by_flags_rec_type IS RECORD(
    ship_from           VARCHAR2(1),
    customer            VARCHAR2(1),
    intmed_ship_to      VARCHAR2(1),
    carrier             VARCHAR2(1),
    mode_of_transport   VARCHAR2(1),
    service_level       VARCHAR2(1),
    fob                 VARCHAR2(1),
    freight_terms       VARCHAR2(1),
    loading_sequence    VARCHAR2(1),
    ship_to_code        VARCHAR2(1),
    ship_to_country     VARCHAR2(1),
    ship_to_state       VARCHAR2(1),
    ship_to_city        VARCHAR2(1),
    ship_to_postal_code VARCHAR2(1),
    ship_to_zone        NUMBER

);


--========================================================================
-- TYPE : group_by_flags_tab_type
--
-- COMMENT   : Table containing the grouping rules.
--========================================================================
TYPE group_by_flags_tab_type IS TABLE OF group_by_flags_rec_type INDEX BY binary_integer;


--========================================================================
-- TYPE : select_del_flags_rec_type
--
-- COMMENT   : Contains the delivery selection criteria specified while
--             submitting the conolidation batch.
--========================================================================
TYPE select_del_flags_rec_type IS RECORD(
    org_id                         NUMBER,
    rule_id                        NUMBER,
    consol_ship_to_loc_id          NUMBER,
    consol_shipto_override_flag    VARCHAR2(1),
    delivery_name_from             VARCHAR2(30),
    delivery_name_to               VARCHAR2(30),
    pick_up_DATE_starts_within     NUMBER,
    pick_up_DATE_ends_within       NUMBER,
    drop_off_DATE_starts_within    NUMBER,
    drop_off_DATE_ends_within      NUMBER,
    pick_release_batch_id          NUMBER,
    customer_id                    NUMBER,
    fob_code                       VARCHAR2(30),
    freight_terms_code             VARCHAR2(30),
    carrier_id                     NUMBER,
    mode_of_transport              VARCHAR2(30),
    service_level                  VARCHAR2(30),
    loading_sequence               NUMBER,
    intmed_ship_to_loc_id          NUMBER,
    ulti_ship_to_loc_id            NUMBER,
    ulti_ship_to_region_id         NUMBER,
    ulti_ship_to_zip_from          VARCHAR2(30),
    ulti_ship_to_zip_to            VARCHAR2(30),
    ulti_ship_to_zone_id           NUMBER,
    inc_staged_del_flag            VARCHAR2(1),
    inc_del_assgnd_trip_flag       VARCHAR2(1),
    create_deconsol_trips_flag     VARCHAR2(1),
    route_trips_flag               VARCHAR2(1),
    rate_trips_flag                VARCHAR2(1),
    trip_name_prefix               VARCHAR2(30),
    max_trip_weight                NUMBER,
    max_trip_weight_uom            VARCHAR2(3)
);


--===================
-- PROCEDURES
--===================

--========================================================================
-- PROCEDURE : Schedule_Batch
--
-- PARAMETERS: errbuf                  Concurrent request error buffer
--             retcode                 Concurrent request return code
--             p_batch_id              Concurrent submission batch id
--             p_log_level             Concurrent request log level
--
-- COMMENT   : This procedure is the entry point of the MDC SRS request.
--             The procedure accepts the batch id for which consolidation
--             is requested.
--========================================================================
PROCEDURE Schedule_Batch(
        errbuf        OUT NOCOPY  VARCHAR2,
        retcode       OUT NOCOPY  VARCHAR2,
        p_batch_id    IN          NUMBER,
        p_log_level   IN          NUMBER);


--========================================================================
-- PROCEDURE : Get_Batch_Parameters
--
-- PARAMETERS: p_batch_id              Concurrent submission batch id
--             x_sel_del_attr          Delivery selection parameters
--             x_return_status         Return status
--
-- COMMENT   : This procedure gets the delivery selection criteria specified
--             for the batch.
--========================================================================
PROCEDURE Get_Batch_Parameters(
        p_batch_id        IN    NUMBER,
        x_sel_del_attr    OUT NOCOPY    select_del_flags_rec_type,
        x_return_status   OUT NOCOPY  VARCHAR2);


--========================================================================
-- PROCEDURE : Get_Deliveries
--
-- PARAMETERS: p_sel_del_attr          Delivery selection parameters
--             x_delivery_tab          Deliveries selected for consolidation
--             x_delivery_addnl_attr_tab         Deliveries selected for consolidation
--             x_return_status         Return status
--
-- COMMENT   : This procedure fetches the deliveries to be consolidated.
--========================================================================
PROCEDURE Get_Deliveries(
        p_sel_del_attr              IN            select_del_flags_rec_type,
        x_delivery_tab              OUT NOCOPY    WSH_FTE_CONSTRAINT_FRAMEWORK.delivery_ccinfo_tab_type,
        x_delivery_addnl_attr_tab   OUT NOCOPY    addnl_del_attr_tab_type,
        x_return_status             OUT NOCOPY           VARCHAR2);


--========================================================================
-- PROCEDURE : Set_Intermediate_Location
--
-- PARAMETERS: p_consol_loc_id         Default intermediate location id
--             p_override_ship_to_flag         Intermediate location override flag
--             p_rule_zone_id          Zone specified in the grouping rule
--             x_delivery_tab          Delivery records
--             x_delivery_addnl_attr_tab         Delivery records
--             x_failed_records        Deliveries which failed to get intermedidate location
--             x_return_status         Return status
--
-- COMMENT   : This procedure updates the delivery records with the intermediate
--             location. The intermediate location is fecthed by calling
--             constraints engine which futher checks the Regions form
--             for an intermediate location, if required. The default intermediate
--             location is applied if the constraints engine fails to fecth
--             an intermediate location. If the override flag is set,
--             all the deliveries are updated with the default value.
--========================================================================
PROCEDURE Set_Intermediate_Location(
        p_consol_loc_id            IN    NUMBER,
        p_override_ship_to_flag    IN    VARCHAR2,
        p_rule_zone_id             IN    NUMBER,
        x_delivery_tab             IN OUT NOCOPY    WSH_FTE_CONSTRAINT_FRAMEWORK.delivery_ccinfo_tab_type,
        x_delivery_addnl_attr_tab  IN OUT NOCOPY    addnl_del_attr_tab_type,
        x_failed_records           IN OUT NOCOPY    WSH_UTIL_CORE.id_tab_type,
        x_return_status            OUT  NOCOPY   VARCHAR2);


--========================================================================
-- PROCEDURE : Get_Grouping_Attrs
--
-- PARAMETERS: p_grouping_rule_id      Consolidation grouping rule id
--             x_group_by_flags        Grouping attributes
--             x_return_status         Return status
--
-- COMMENT   : This procedure gets the grouping attributes for the
--             rule specified.
--========================================================================
PROCEDURE Get_Grouping_Attrs(
        p_grouping_rule_id    IN    NUMBER,
        x_group_by_flags      OUT NOCOPY    group_by_flags_rec_type,
        x_return_status       OUT NOCOPY   VARCHAR2);


--========================================================================
-- PROCEDURE : Get_Hash_Value
--
-- PARAMETERS: p_delivery_rec          Delivery record
--             p_delivery_addnl_attr_rec          Delivery record
--             p_group_by_flags        Grouping attributes
--             p_hash_base             Hash base
--             p_hash_size             Hash size
--             x_hash_string           Hash string
--             x_hash_value            Hash value
--             x_return_status         Return status
--
-- COMMENT   : This procedure takes the delivery records and the
--             grouping attributes and return the hash value. The hash
--             size and base also needs to be passed.
--             The procedure also clears out all the non-grouping
--             attributes from the delivery records
--========================================================================
PROCEDURE Get_Hash_Value(
        x_delivery_rec              IN OUT NOCOPY    WSH_FTE_CONSTRAINT_FRAMEWORK.delivery_ccinfo_rec_type,
        x_delivery_addnl_attr_rec   IN OUT NOCOPY    addnl_del_attr_rec_type,
        p_group_by_flags            IN    group_by_flags_rec_type,
        p_hash_base                 IN    NUMBER,
        p_hash_size                 IN    NUMBER,
        x_hash_string               OUT NOCOPY  VARCHAR2,
        x_hash_value                OUT NOCOPY  NUMBER,
        x_return_status             OUT NOCOPY   VARCHAR2);


--========================================================================
-- PROCEDURE : Create_Consolidations
--
-- PARAMETERS: x_delivery_tab          Delivery records
--             x_delivery_addnl_attr_tab          Delivery records
--             p_group_tab             Groups created
--             p_max_trip_weight       Max weight of consolidation trip
--             p_max_weight_uom        Max weight uom
--             p_trip_name_prefix      Consolidation trip name prefix
--             x_consol_trip_id        Consolidation trip ids
--             x_consol_del_id         Consolidation delivery ids
--             x_trips_all             List of all the trips created
--             x_failed_records        Records that failed consolidation
--             x_return_status         Return status
--
-- COMMENT   : This procedure takes the delivery records and the
--             groups created and creates consolidated deliveries.
--             The max consolidation trip weight and trip name prefix
--             can also be specified.
--========================================================================
PROCEDURE Create_Consolidations(
        x_delivery_tab              IN OUT NOCOPY    WSH_FTE_CONSTRAINT_FRAMEWORK.delivery_ccinfo_tab_type,
        x_delivery_addnl_attr_tab   IN OUT NOCOPY    addnl_del_attr_tab_type,
        p_group_tab                 IN    grp_attr_tab_type,
        p_max_trip_weight           IN    NUMBER,
        p_max_weight_uom            IN    VARCHAR2,
        p_trip_name_prefix          IN    VARCHAR2,
        x_consol_trip_id            OUT NOCOPY    WSH_UTIL_CORE.id_tab_type,
        x_consol_del_id             OUT NOCOPY    WSH_UTIL_CORE.id_tab_type,
        x_trips_all                 OUT NOCOPY    WSH_UTIL_CORE.id_tab_type,
        x_failed_records            OUT NOCOPY    WSH_UTIL_CORE.id_tab_type,
        x_return_status             OUT NOCOPY   VARCHAR2);


--========================================================================
-- PROCEDURE : Create_Deconsol_Trips
--
-- PARAMETERS: x_delivery_tab          Delivery records
--             x_delivery_addnl_attr_tab          Delivery records
--             p_consol_trip_id        Consolidation trip ids
--             x_trips_all             List of all the trips created
--             x_return_status         Return status
--
-- COMMENT   : This procedure takes the delivery records and and creates
--             cdeconsolidation trips for the deliveries.
--========================================================================
PROCEDURE Create_Deconsol_Trips(
        x_delivery_tab              IN OUT NOCOPY    WSH_FTE_CONSTRAINT_FRAMEWORK.delivery_ccinfo_tab_type,
        x_delivery_addnl_attr_tab   IN OUT NOCOPY    addnl_del_attr_tab_type,
        p_consol_trip_id            IN    WSH_UTIL_CORE.id_tab_type,
        p_trip_name_prefix          IN    VARCHAR2,
        x_trips_all                 IN OUT NOCOPY    WSH_UTIL_CORE.id_tab_type,
        x_return_status             OUT NOCOPY   VARCHAR2);

END WSH_MDC_SRS;

 

/
