--------------------------------------------------------
--  DDL for Package WSM_SERIAL_SUPPORT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSM_SERIAL_SUPPORT_GRP" AUTHID CURRENT_USER AS
/* $Header: WSMGSERS.pls 120.0.12000000.1 2007/01/12 05:35:36 appldev ship $ */

-- Serial Number Record definition
-- Will be used in all the OSFM modules
TYPE WSM_SERIAL_NUM_REC is record
(
Serial_Number			mtl_serial_numbers.serial_number%type                  ,
Assembly_item_id		number						       , -- added for attributes support during move..
header_id			number						       , -- added for attributes support during move..
Generate_serial_number		number                                                 ,
Generate_for_qty		number                                                 ,
Action_flag			number                                                 ,
Current_wip_entity_name		wip_entities.wip_entity_name%type                      ,
Changed_wip_entity_name		wip_entities.wip_entity_name%type                      ,
Current_wip_entity_id		wip_entities.wip_entity_id%type                        ,
Changed_wip_entity_id		wip_entities.wip_entity_id%type                        ,
serial_attribute_category   	mtl_serial_numbers.serial_attribute_category%type   ,
territory_code              	mtl_serial_numbers.territory_code%type              ,
origination_date            	mtl_serial_numbers.origination_date%type            ,
c_attribute1                	mtl_serial_numbers.c_attribute1%type                ,
c_attribute2                	mtl_serial_numbers.c_attribute2%type                ,
c_attribute3                	mtl_serial_numbers.c_attribute3%type                ,
c_attribute4                	mtl_serial_numbers.c_attribute4%type                ,
c_attribute5                	mtl_serial_numbers.c_attribute5%type                ,
c_attribute6                	mtl_serial_numbers.c_attribute6%type                ,
c_attribute7                	mtl_serial_numbers.c_attribute7%type                ,
c_attribute8                	mtl_serial_numbers.c_attribute8%type                ,
c_attribute9                	mtl_serial_numbers.c_attribute9%type                ,
c_attribute10               	mtl_serial_numbers.c_attribute10%type               ,
c_attribute11               	mtl_serial_numbers.c_attribute11%type               ,
c_attribute12               	mtl_serial_numbers.c_attribute12%type               ,
c_attribute13               	mtl_serial_numbers.c_attribute13%type               ,
c_attribute14               	mtl_serial_numbers.c_attribute14%type               ,
c_attribute15               	mtl_serial_numbers.c_attribute15%type               ,
c_attribute16               	mtl_serial_numbers.c_attribute16%type               ,
c_attribute17               	mtl_serial_numbers.c_attribute17%type               ,
c_attribute18               	mtl_serial_numbers.c_attribute18%type               ,
c_attribute19               	mtl_serial_numbers.c_attribute19%type               ,
c_attribute20               	mtl_serial_numbers.c_attribute20%type               ,
d_attribute1                	mtl_serial_numbers.d_attribute1%type                ,
d_attribute2                	mtl_serial_numbers.d_attribute2%type                ,
d_attribute3                	mtl_serial_numbers.d_attribute3%type                ,
d_attribute4                	mtl_serial_numbers.d_attribute4%type                ,
d_attribute5                	mtl_serial_numbers.d_attribute5%type                ,
d_attribute6                	mtl_serial_numbers.d_attribute6%type                ,
d_attribute7                	mtl_serial_numbers.d_attribute7%type                ,
d_attribute8                	mtl_serial_numbers.d_attribute8%type                ,
d_attribute9                	mtl_serial_numbers.d_attribute9%type                ,
d_attribute10               	mtl_serial_numbers.d_attribute10%type               ,
n_attribute1                	mtl_serial_numbers.n_attribute1%type                ,
n_attribute2                	mtl_serial_numbers.n_attribute2%type                ,
n_attribute3                	mtl_serial_numbers.n_attribute3%type                ,
n_attribute4                	mtl_serial_numbers.n_attribute4%type                ,
n_attribute5                	mtl_serial_numbers.n_attribute5%type                ,
n_attribute6                	mtl_serial_numbers.n_attribute6%type                ,
n_attribute7                	mtl_serial_numbers.n_attribute7%type                ,
n_attribute8                	mtl_serial_numbers.n_attribute8%type                ,
n_attribute9                	mtl_serial_numbers.n_attribute9%type                ,
n_attribute10               	mtl_serial_numbers.n_attribute10%type               ,
status_id                   	mtl_serial_numbers.status_id%type                   ,
time_since_new              	mtl_serial_numbers.time_since_new%type              ,
cycles_since_new            	mtl_serial_numbers.cycles_since_new%type            ,
time_since_overhaul         	mtl_serial_numbers.time_since_overhaul%type         ,
cycles_since_overhaul       	mtl_serial_numbers.cycles_since_overhaul%type       ,
time_since_repair           	mtl_serial_numbers.time_since_repair%type           ,
cycles_since_repair         	mtl_serial_numbers.cycles_since_repair%type         ,
time_since_visit            	mtl_serial_numbers.time_since_visit%type            ,
cycles_since_visit          	mtl_serial_numbers.cycles_since_visit%type          ,
time_since_mark             	mtl_serial_numbers.time_since_mark%type             ,
cycles_since_mark           	mtl_serial_numbers.cycles_since_mark%type           ,
number_of_repairs           	mtl_serial_numbers.number_of_repairs%type           ,
attribute_category          	mtl_serial_numbers.attribute_category%type          ,
attribute1                  	mtl_serial_numbers.attribute1%type                  ,
attribute2                  	mtl_serial_numbers.attribute2%type                  ,
attribute3                  	mtl_serial_numbers.attribute3%type                  ,
attribute4                  	mtl_serial_numbers.attribute4%type                  ,
attribute5                  	mtl_serial_numbers.attribute5%type                  ,
attribute6                  	mtl_serial_numbers.attribute6%type                  ,
attribute7                  	mtl_serial_numbers.attribute7%type                  ,
attribute8                  	mtl_serial_numbers.attribute8%type                  ,
attribute9                  	mtl_serial_numbers.attribute9%type                  ,
attribute10                 	mtl_serial_numbers.attribute10%type                 ,
attribute11                 	mtl_serial_numbers.attribute11%type                 ,
attribute12                 	mtl_serial_numbers.attribute12%type                 ,
attribute13                 	mtl_serial_numbers.attribute13%type                 ,
attribute14			mtl_serial_numbers.attribute14%type		    ,
attribute15			mtl_serial_numbers.attribute15%type
);

TYPE WSM_SERIAL_NUM_TBL is table of WSM_SERIAL_NUM_REC index by binary_integer;

-- This procedure will be called from the WIP move processor for backflush processing of intreface txn
-- If the txn is an undo or assembly return txn for a lot based job, populate_components will be invoked.
-- else the WIP API will be invoked
Procedure backflush_comp (p_wipEntityID      IN        NUMBER,
	                  p_orgID            IN        NUMBER,
	                  p_primaryQty       IN        NUMBER,
	                  p_txnDate          IN        DATE,
	                  p_txnHdrID         IN        NUMBER,
	                  p_txnType          IN        NUMBER,
	                  p_fmOp             IN        NUMBER,
	                  p_fmStep           IN        NUMBER,
	                  p_toOp             IN        NUMBER,
	                  p_toStep           IN        NUMBER,
	                  p_movTxnID         IN        NUMBER,
	                  p_cplTxnID         IN        NUMBER:= NULL,
	                  p_mtlTxnMode       IN        NUMBER,
	                  p_reasonID         IN        NUMBER := NULL,
	                  p_reference        IN        VARCHAR2 := NULL,
	                  p_init_msg_list    IN      VARCHAR2,
			  x_lotSerRequired   OUT NOCOPY NUMBER,
	                  x_returnStatus     OUT NOCOPY VARCHAR2,
                          x_error_msg        OUT NOCOPY VARCHAR2,
                          x_error_count      OUT NOCOPY  NUMBER
                        );

-- Populate MMTT,MTLT and MSNT for an assembly return/undo transaction for a lot based job
-- based on the previous move transaction records in MMT,MTL,MUT.

procedure populate_components(p_wip_entity_id  		IN 	   NUMBER,
			      p_organization_id		IN	   NUMBER,
			      p_move_txn_id		IN	   NUMBER,
			      p_move_txn_type		IN	   NUMBER,
			      p_txn_date		IN	   DATE,
			      p_mtl_txn_hdr_id  	IN         NUMBER,
			      p_compl_txn_id		IN         NUMBER,
			      x_return_status   	OUT NOCOPY VARCHAR2,
			      x_error_count   		OUT NOCOPY NUMBER,
			      x_error_msg     		OUT NOCOPY VARCHAR2
			     );


END WSM_Serial_support_GRP;

 

/
