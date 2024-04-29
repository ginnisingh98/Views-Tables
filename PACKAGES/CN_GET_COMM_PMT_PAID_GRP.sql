--------------------------------------------------------
--  DDL for Package CN_GET_COMM_PMT_PAID_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_GET_COMM_PMT_PAID_GRP" AUTHID CURRENT_USER AS
-- $Header: cnggcpps.pls 120.0 2005/08/08 00:16:34 appldev noship $

-- -------------------------------------------------------------------------+
-- Get the compensation earned and compensation paid from OIC.
-- -------------------------------------------------------------------------+
-- Start of comments
--    API name        : get_comm_and_paid_pmt
--    Type            : Group.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_person_id           IN NUMBER       Required
--                      p_start_date          IN DATE         Required
--                      p_end_date            IN DATE         Required
--                      p_target_currency_code IN VARCHAR2    Required
--                      p_proration_flag      IN VARCHAR2     Optional
--
--    OUT             : x_return_status       OUT VARCHAR2(1)
--                      x_msg_count           OUT NUMBER
--                      x_msg_data            OUT VARCHAR2(2000)
--                      x_comp_earned         OUT NUMBER
--                      x_comp_paid           OUT NUMBER
--                      x_new_start_date      OUT DATE
--                      x_new_end_date        OUT DATE
--
--    Version :         Current version       1.0
--
--    Notes           : Note text
--
-- End of comments
PROCEDURE get_comm_and_paid_pmt
(
    p_api_version IN NUMBER,
    p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    p_person_id IN NUMBER,
    p_start_date IN DATE,
    p_end_date IN DATE,
    p_target_currency_code IN VARCHAR2,
    p_proration_flag IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    x_comp_earned OUT NOCOPY NUMBER,
    x_comp_paid OUT NOCOPY NUMBER,
    x_new_start_date OUT NOCOPY Date,
    x_new_end_date OUT NOCOPY Date
);

END CN_GET_COMM_PMT_PAID_GRP;

 

/
