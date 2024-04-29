--------------------------------------------------------
--  DDL for Package QPR_AW_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QPR_AW_INTERFACE_PVT" AUTHID CURRENT_USER AS
/* $Header: QPRAWINFCS.pls 120.0 2007/10/11 13:12:59 agbennet noship $ */
procedure detach_aw (p_aw_name IN varchar2,x_return_status OUT NOCOPY varchar2);
procedure attach_aw (p_aw_name IN varchar2,p_attach_mode IN varchar2,x_return_status OUT NOCOPY varchar2);
/*procedure writeback_aw(dimTable in QPR_DIM_TABLE,measTable in QPR_MEAS_TABLE,x_return_status out NOCOPY varchar2);
procedure executeModel(modelName in varchar2, modelDimension in varchar2, modelMeasName in varchar2, modelExecScope in QPR_DIM_TABLE, writeBackMeas in QPR_MEAS_MET_TABLE,x_return_status out NOCOPY varchar2);
procedure commitData(commitMeas in QPR_MEAS_MET_TABLE,x_return_status out NOCOPY varchar2);
procedure handleMeas(commitMeas in QPR_MEAS_MET_TABLE,dim in QPR_MEAS_MET_TABLE,acquire in varchar2,x_return_status OUT NOCOPY varchar2);*/
oracleNull CONSTANT varchar2(15) := 'ORACLENULL';
END QPR_AW_INTERFACE_PVT;

/
