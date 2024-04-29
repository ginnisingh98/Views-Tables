--------------------------------------------------------
--  DDL for Package MTL_CCEOI_ACTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_CCEOI_ACTION_PVT" AUTHID CURRENT_USER AS
/* $Header: INVVCCAS.pls 120.1 2005/06/19 23:22:48 appldev ship $ */
  --
  -- Insert the given row into the interface table.
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data OUT
  --parameters to comply with GSCC File.Sql.39 standard. Bug:4410902
  PROCEDURE Export_CountRequest(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  p_interface_rec IN MTL_CCEOI_VAR_PVT.INV_CCEOI_TYPE )
;
  --
  -- Create unscheduled count requests
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data OUT
  --parameters to comply with GSCC File.Sql.39 standard. Bug:4410902
  PROCEDURE Create_CountRequest(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  p_simulate IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_interface_rec IN MTL_CCEOI_VAR_PVT.INV_CCEOI_TYPE )
;
  --
  -- processed count request from the interface table
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data OUT
  --parameters to comply with GSCC File.Sql.39 standard. Bug:4410902
  PROCEDURE Process_CountRequest(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  p_simulate IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_interface_rec IN MTL_CCEOI_VAR_PVT.INV_CCEOI_TYPE )
;
  --
  -- Validate the records in the interface table
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data OUT
  --parameters to comply with GSCC File.Sql.39 standard. Bug:4410902
  PROCEDURE Validate_CountRequest(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_NONE,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  p_interface_rec IN MTL_CCEOI_VAR_PVT.INV_CCEOI_TYPE )
;
  --
  -- validates and simulates records from interface table
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data OUT
  --parameters to comply with GSCC File.Sql.39 standard. Bug:4410902
  PROCEDURE ValSim_CountRequest(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  p_interface_rec IN MTL_CCEOI_VAR_PVT.INV_CCEOI_TYPE )
;
  --
  -- Updated or inserted the interface record table
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data OUT
  --parameters to comply with GSCC File.Sql.39 standard. Bug:4410902
  PROCEDURE Update_Insert_CountRequest(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  p_interface_rec IN MTL_CCEOI_VAR_PVT.INV_CCEOI_TYPE )
;
END MTL_CCEOI_ACTION_PVT;

 

/
