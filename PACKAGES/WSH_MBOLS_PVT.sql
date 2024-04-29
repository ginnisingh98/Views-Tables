--------------------------------------------------------
--  DDL for Package WSH_MBOLS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_MBOLS_PVT" AUTHID CURRENT_USER AS
-- $Header: WSHMBTHS.pls 120.0 2005/05/26 17:05:35 appldev noship $

--========================================================================
-- PROCEDURE : Generate_MBOL
--
-- PARAMETERS: p_trip_id              trip id
--             x_sequence_number      MBOL number
--             x_return_status        return status
--
--========================================================================
PROCEDURE Generate_MBOL(
  p_trip_id          IN          NUMBER,
  x_sequence_number  OUT  NOCOPY VARCHAR2,
  x_return_status    OUT  NOCOPY VARCHAR2
);

--========================================================================
-- PROCEDURE : Generate_BOLs
--
-- PARAMETERS: p_trip_id              trip id
--             x_return_status        return status
--
--========================================================================
PROCEDURE Generate_BOLs(
  p_trip_id          IN          NUMBER,
  x_return_status    OUT  NOCOPY VARCHAR2
);

--========================================================================
-- PROCEDURE : Print_MBOL
--
-- PARAMETERS: p_trip_id              trip id
--             p_generate_bols        generate related BOLs if 'Y'
--             x_return_status        return status
--
--========================================================================
PROCEDURE Print_MBOL(
  p_trip_id          IN          NUMBER,
  p_generate_bols    IN          VARCHAR2 DEFAULT 'N',
  x_return_status    OUT  NOCOPY VARCHAR2
);

--========================================================================
-- PROCEDURE : Print_BOLs
--
-- PARAMETERS: p_trip_id              trip id
--             x_return_status        return status
--
--========================================================================
PROCEDURE Print_BOLs(
  p_trip_id          IN          NUMBER,
  p_conc_request_id  IN		 NUMBER,
  x_return_status    OUT  NOCOPY VARCHAR2
);

--========================================================================
-- PROCEDURE : Cancel_MBOL
--
-- PARAMETERS: p_trip_id         trip id
--            x_return_status  return status
--
--========================================================================

PROCEDURE cancel_mbol
  ( p_trip_id			  IN NUMBER
    , x_return_status		  OUT NOCOPY  VARCHAR2
  );

--========================================================================
-- PROCEDURE : Get_Organization_of_MBOL
--
-- PARAMETERS: p_trip_id		trip id
--            x_organization_id		organization of MBOL
--            x_return_status		return status
--
--========================================================================

PROCEDURE Get_Organization_of_MBOL(
  p_trip_id          IN         NUMBER,
  x_organization_id  OUT NOCOPY NUMBER,
  x_return_status    OUT NOCOPY VARCHAR2
);



END wsh_mbols_pvt;

 

/
