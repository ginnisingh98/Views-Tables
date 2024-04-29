--------------------------------------------------------
--  DDL for Package OKL_XLA_EVENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_XLA_EVENTS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRCSES.pls 120.0 2007/02/22 21:40:14 racheruv noship $ */

-------------------------------------------------------------------------------
-- Event creation routines
-------------------------------------------------------------------------------
-- Public function to raise an accounting event in SLA and return the event id.
FUNCTION create_event(
    p_api_version           IN  NUMBER
   ,p_init_msg_list         IN  VARCHAR2
   ,x_return_status         OUT NOCOPY VARCHAR2
   ,x_msg_count             OUT NOCOPY NUMBER
   ,x_msg_data              OUT NOCOPY VARCHAR2
   ,p_tcn_id                IN  NUMBER
   ,p_gl_date               IN  DATE
   ,p_action_type           IN  VARCHAR2
   ,p_representation_code   IN  VARCHAR2
   ) RETURN INTEGER;

-------------------------------------------------------------------------------
-- Event updation routines
-------------------------------------------------------------------------------
-- Public API to update the attributes of an event. Based on the parameters
-- passed, API calls an appropriate SLA's update event APIs.
PROCEDURE update_event(
    p_api_version           IN  NUMBER
   ,p_init_msg_list         IN  VARCHAR2
   ,x_return_status         OUT NOCOPY VARCHAR2
   ,x_msg_count             OUT NOCOPY NUMBER
   ,x_msg_data              OUT NOCOPY VARCHAR2
   ,p_tcn_id                IN  NUMBER
   ,p_gl_date               IN  DATE     DEFAULT NULL
   ,p_action_type           IN  VARCHAR2 DEFAULT NULL
   ,p_event_id              IN  NUMBER
   ,p_event_type_code       IN  VARCHAR2
   ,p_event_status_code     IN  VARCHAR2 DEFAULT NULL
   ,p_event_number          IN  NUMBER   DEFAULT NULL
   ,p_update_ref_info       IN  VARCHAR2 DEFAULT 'N'
   ,p_reference_info        IN  xla_events_pub_pkg.t_event_reference_info DEFAULT NULL
   ,p_representation_code   IN  VARCHAR2);

-- API to update the event date. This is called by Period Sweep Program.
-- p_gl_date represents the new event date that is stamped on events.
PROCEDURE update_event(
    p_api_version           IN  NUMBER
   ,p_init_msg_list         IN  VARCHAR2
   ,x_return_status         OUT NOCOPY VARCHAR2
   ,x_msg_count             OUT NOCOPY NUMBER
   ,x_msg_data              OUT NOCOPY VARCHAR2
   ,p_tcn_id                IN  NUMBER
   ,p_event_id              IN  NUMBER
   ,p_gl_date               IN  DATE);

-- API to update event status of one or more matching events within an entity
PROCEDURE update_event_status(
    p_api_version           IN  NUMBER
   ,p_init_msg_list         IN  VARCHAR2
   ,x_return_status         OUT NOCOPY VARCHAR2
   ,x_msg_count             OUT NOCOPY NUMBER
   ,x_msg_data              OUT NOCOPY VARCHAR2
   ,p_tcn_id                IN  NUMBER
   ,p_gl_date               IN  DATE
   ,p_action_type           IN  VARCHAR2
   ,p_representation_code   IN  VARCHAR2
   ,p_event_status_code     IN  VARCHAR2);

TYPE tcn_tbl_type IS TABLE OF okl_trx_contracts_all.id%TYPE INDEX BY BINARY_INTEGER;
TYPE try_tbl_type IS TABLE OF okl_trx_contracts_all.try_id%TYPE INDEX BY BINARY_INTEGER;
TYPE ledger_tbl_type IS TABLE OF okl_trx_contracts_all.set_of_books_id%TYPE INDEX BY BINARY_INTEGER;

-- API to update the event status in bulk. If p_action_type is null, then
-- events for both create and reverse event types are updated.
PROCEDURE update_bulk_event_statuses(
    p_api_version        IN  NUMBER
   ,p_init_msg_list      IN  VARCHAR2
   ,x_return_status      OUT NOCOPY VARCHAR2
   ,x_msg_count          OUT NOCOPY NUMBER
   ,x_msg_data           OUT NOCOPY VARCHAR2
   ,p_tcn_tbl            IN  tcn_tbl_type
   ,p_try_id             IN  NUMBER
   ,p_ledger_id          IN  NUMBER
   ,p_action_type        IN  VARCHAR2 DEFAULT NULL
   ,p_event_status_code  IN  VARCHAR2
   );

-------------------------------------------------------------------------------
-- Event deletion routines
-------------------------------------------------------------------------------
-- API to delete a single unaccounted event based on event id.
PROCEDURE delete_event(
    p_api_version           IN  NUMBER
   ,p_init_msg_list         IN  VARCHAR2
   ,x_return_status         OUT NOCOPY VARCHAR2
   ,x_msg_count             OUT NOCOPY NUMBER
   ,x_msg_data              OUT NOCOPY VARCHAR2
   ,p_tcn_id                IN  NUMBER
   ,p_event_id              IN  NUMBER
   ,p_representation_code   IN  VARCHAR2);

-- API to delete all events for a transaction that meet the criteria. This
-- API deletes events that belong to the given event class, event type, and
-- event date. Returns number of events deleted. Returns -1 if an error occurs.
FUNCTION delete_events(
    p_api_version           IN  NUMBER
   ,p_init_msg_list         IN  VARCHAR2
   ,x_return_status         OUT NOCOPY VARCHAR2
   ,x_msg_count             OUT NOCOPY NUMBER
   ,x_msg_data              OUT NOCOPY VARCHAR2
   ,p_tcn_id                IN  NUMBER
   ,p_action_type           IN  VARCHAR2
   ,p_gl_date               IN  DATE
   ,p_representation_code   IN  VARCHAR2)
RETURN INTEGER;

-------------------------------------------------------------------------------
-- Event information routines
-------------------------------------------------------------------------------
-- API to return the information about an event in a record structure.
FUNCTION get_event_info(
    p_api_version           IN  NUMBER
   ,p_init_msg_list         IN  VARCHAR2
   ,x_return_status         OUT NOCOPY VARCHAR2
   ,x_msg_count             OUT NOCOPY NUMBER
   ,x_msg_data              OUT NOCOPY VARCHAR2
   ,p_tcn_id                IN  NUMBER
   ,p_event_id              IN  NUMBER
   ,p_representation_code   IN  VARCHAR2)
RETURN xla_events_pub_pkg.t_event_info;

-- API to return information for one or more events within a transaction for
-- a given criteria. An array of records is returned with the event info.
-- If action_type is passed, then the events corresponding to that event_type -- will be returned.
-- If p_action_type is null, then all events for that event class will be
-- returned.
-- If gl_date is passed, all events for the transaction matching event date will be
-- returned.
FUNCTION get_array_event_info(
    p_api_version           IN  NUMBER
   ,p_init_msg_list         IN  VARCHAR2
   ,x_return_status         OUT NOCOPY VARCHAR2
   ,x_msg_count             OUT NOCOPY NUMBER
   ,x_msg_data              OUT NOCOPY VARCHAR2
   ,p_tcn_id                IN  NUMBER
   ,p_action_type           IN  VARCHAR2 DEFAULT NULL
   ,p_gl_date               IN  DATE     DEFAULT NULL
   ,p_event_status_code     IN  VARCHAR2 DEFAULT NULL
   ,p_representation_code   IN  VARCHAR2)
RETURN xla_events_pub_pkg.t_array_event_info;

-- API to provide the status for a given event.
FUNCTION get_event_status(
    p_api_version           IN  NUMBER
   ,p_init_msg_list         IN  VARCHAR2
   ,x_return_status         OUT NOCOPY VARCHAR2
   ,x_msg_count             OUT NOCOPY NUMBER
   ,x_msg_data              OUT NOCOPY VARCHAR2
   ,p_tcn_id                IN  NUMBER
   ,p_event_id              IN  NUMBER
   ,p_representation_code   IN  VARCHAR2)
 RETURN VARCHAR2;

-- API to check if an event has been raised for the transaction.
-- If p_action_type is passed, corresponding event for Create or Reverse
-- action will be identified, otherwise existence of event for the transaction
-- is checked and value returned.
PROCEDURE event_exists(p_api_version        IN  NUMBER
                      ,p_init_msg_list      IN  VARCHAR2
                      ,x_return_status      OUT NOCOPY VARCHAR2
                      ,x_msg_count          OUT NOCOPY NUMBER
                      ,x_msg_data           OUT NOCOPY VARCHAR2
                      ,p_tcn_id             IN  NUMBER
                      ,p_action_type        IN  VARCHAR2
                      ,x_event_id           OUT NOCOPY NUMBER
                      ,x_event_date         OUT NOCOPY DATE);

g_application_id      CONSTANT NUMBER := 540;
g_app_name            CONSTANT VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;
g_unexpected_error    CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
g_sqlerrm_token       CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
g_sqlcode_token       CONSTANT VARCHAR2(200) := 'OKL_SQLcode';
g_pkg_name            CONSTANT VARCHAR2(30) := 'OKL_XLA_EVENTS';

END OKL_XLA_EVENTS_PVT;

/
