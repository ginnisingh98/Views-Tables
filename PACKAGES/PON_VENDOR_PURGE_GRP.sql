--------------------------------------------------------
--  DDL for Package PON_VENDOR_PURGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_VENDOR_PURGE_GRP" AUTHID CURRENT_USER as
/* $Header: PONVDPGS.pls 120.0 2005/06/01 14:43:27 appldev noship $ */

function validate_vendor_purge (
  p_api_version   IN         NUMBER,
  p_init_msg_list IN         VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count     OUT NOCOPY NUMBER,
  x_msg_data      OUT NOCOPY VARCHAR2,
  p_vendor_id 	IN	     NUMBER)
RETURN VARCHAR2;

procedure vendor_purge (
  p_api_version   IN         NUMBER,
  p_init_msg_list IN         VARCHAR2,
  p_commit        IN         VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count     OUT NOCOPY NUMBER,
  x_msg_data      OUT NOCOPY VARCHAR2,
  p_vendor_id 	IN	     NUMBER);


END PON_VENDOR_PURGE_GRP;

 

/
