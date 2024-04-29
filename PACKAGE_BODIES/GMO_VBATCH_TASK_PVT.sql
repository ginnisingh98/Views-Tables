--------------------------------------------------------
--  DDL for Package Body GMO_VBATCH_TASK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMO_VBATCH_TASK_PVT" AS
/* $Header: GMOVVTKB.pls 120.1 2007/06/21 06:16:59 rvsingh noship $ */

function is_wms_installed return varchar2 is
begin
	if (inv_install.adv_inv_installed(NULL)) then
		return 'TRUE';
	else
		return 'FALSE';
	end if;
end is_wms_installed;

procedure get_resource_txn_end_date(
p_start_date		   IN DATE
,p_usage		   IN NUMBER
,p_trans_um		   IN VARCHAR2
,x_end_date		   OUT NOCOPY DATE
,x_return_status           OUT NOCOPY VARCHAR2
,x_message_count           OUT NOCOPY NUMBER
,x_message_data            OUT NOCOPY VARCHAR2
) IS

l_usage_time number;
l_txn_usage number;
l_hour_um varchar2(100);
missing_profile_option exception;
uom_conversion_err exception;
BEGIN
	l_hour_um    := fnd_profile.value_specific(name => 'BOM:HOUR_UOM_CODE',user_id => FND_GLOBAL.USER_ID);
	IF (l_hour_um IS NULL) THEN
		RAISE missing_profile_option;
	END IF;
	IF l_hour_um <> p_trans_um THEN
		l_txn_usage := inv_convert.inv_um_convert
			(
			item_id => 0
			,PRECISION          => 5
			,from_quantity      => p_usage
			,from_unit          => p_trans_um
			,to_unit            => l_hour_um
			,from_name          => NULL
			,to_name            => NULL
			);
		IF (l_txn_usage = -99999) THEN
			RAISE uom_conversion_err;
		END IF;
	ELSE
		l_txn_usage := p_usage;
	END IF;
	x_end_date := p_start_date + (l_txn_usage/24);
	x_return_status := fnd_api.g_ret_sts_success;
EXCEPTION
	WHEN missing_profile_option THEN
		x_return_status := fnd_api.g_ret_sts_error;
		FND_MESSAGE.SET_NAME('GME','GME_API_UNABLE_TO_GET_CONSTANT');
		FND_MESSAGE.SET_TOKEN('CONSTANT_NAME','BOM:HOUR_UOM_CODE');
		if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_vbatch_task_pvt.get_resource_txn_end_date', FALSE);
		end if;
		FND_MSG_PUB.ADD;
		FND_MSG_PUB.Count_And_Get (p_count => x_message_count, p_data => x_message_data);

	WHEN uom_conversion_err THEN
		x_return_status:= fnd_api.g_ret_sts_error;
		FND_MESSAGE.SET_NAME('GME','GME_RSRC_USG_NT_CNV_SYUOM');
		FND_MESSAGE.SET_TOKEN('SY_UOM',l_hour_um);
		FND_MESSAGE.SET_TOKEN('RSRC_USG_UOM',p_trans_um);
		if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_vbatch_task_pvt.get_resource_txn_end_date', FALSE);
		end if;
		FND_MSG_PUB.ADD;
		FND_MSG_PUB.Count_And_Get (p_count => x_message_count, p_data => x_message_data);
	WHEN OTHERS THEN
		x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
        	FND_MESSAGE.SET_NAME('GMO','GMO_VBATCH_UNEXPECTED_DB_ERR');
                FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
                FND_MESSAGE.SET_TOKEN('ERROR_CODE',SQLCODE);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_vbatch_task_pvt.get_resource_txn_end_date', FALSE);
                end if;
		FND_MSG_PUB.ADD;
                FND_MSG_PUB.Count_And_Get (p_count => x_message_count, p_data => x_message_data);
END get_resource_txn_end_date;

procedure get_resource_txn_usage(
p_start_date		   IN DATE
,p_end_date		   IN DATE
,p_trans_um		   IN VARCHAR2
,x_usage		   OUT NOCOPY NUMBER
,x_return_status           OUT NOCOPY VARCHAR2
,x_message_count           OUT NOCOPY NUMBER
,x_message_data            OUT NOCOPY VARCHAR2
) IS

l_usage_time number;
l_txn_usage number;
l_hour_um varchar2(100);
missing_profile_option exception;
uom_conversion_err exception;
BEGIN
	l_usage_time := (p_end_date - p_start_date) * 24;
	l_hour_um    := fnd_profile.value_specific(name => 'BOM:HOUR_UOM_CODE',user_id => FND_GLOBAL.USER_ID);
	IF (l_hour_um IS NULL) THEN
		RAISE missing_profile_option;
	END IF;
	IF l_hour_um <> p_trans_um THEN
		l_txn_usage := inv_convert.inv_um_convert
			(
			item_id => 0
			,PRECISION          => 5
			,from_quantity      => l_usage_time
			,from_unit          => l_hour_um
			,to_unit            => p_trans_um
			,from_name          => NULL
			,to_name            => NULL
			);
		IF (l_txn_usage = -99999) THEN
			RAISE uom_conversion_err;
		END IF;
	ELSE
		l_txn_usage := l_usage_time;
	END IF;
	x_return_status := fnd_api.g_ret_sts_success;
	x_usage := l_txn_usage;
EXCEPTION
	WHEN missing_profile_option THEN
		x_return_status := fnd_api.g_ret_sts_error;
		FND_MESSAGE.SET_NAME('GME','GME_API_UNABLE_TO_GET_CONSTANT');
		FND_MESSAGE.SET_TOKEN('CONSTANT_NAME','BOM:HOUR_UOM_CODE');
		if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_vbatch_task_pvt.get_resource_txn_usage', FALSE);
		end if;
		FND_MSG_PUB.ADD;
		FND_MSG_PUB.Count_And_Get (p_count => x_message_count, p_data => x_message_data);

	WHEN uom_conversion_err THEN
		x_return_status:= fnd_api.g_ret_sts_error;
		FND_MESSAGE.SET_NAME('GME','GME_RSRC_USG_NT_CNV_SYUOM');
		FND_MESSAGE.SET_TOKEN('SY_UOM',l_hour_um);
		FND_MESSAGE.SET_TOKEN('RSRC_USG_UOM',p_trans_um);
		if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_vbatch_task_pvt.get_resource_txn_usage', FALSE);
		end if;
		FND_MSG_PUB.ADD;
		FND_MSG_PUB.Count_And_Get (p_count => x_message_count, p_data => x_message_data);
	WHEN OTHERS THEN
		x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
        	FND_MESSAGE.SET_NAME('GMO','GMO_VBATCH_UNEXPECTED_DB_ERR');
                FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
                FND_MESSAGE.SET_TOKEN('ERROR_CODE',SQLCODE);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_vbatch_task_pvt.get_resource_txn_usage', FALSE);
                end if;
		FND_MSG_PUB.ADD;
                FND_MSG_PUB.Count_And_Get (p_count => x_message_count, p_data => x_message_data);
END get_resource_txn_usage;

procedure get_resource_transaction_arr
(
p_resource_transaction_rec in GME_RESOURCE_TXNS_GTMP%ROWTYPE
,x_resource_transaction_rec OUT NOCOPY fnd_table_of_varchar2_255
)
AS
BEGIN

x_resource_transaction_rec := new fnd_table_of_varchar2_255();

x_resource_transaction_rec.extend;
x_resource_transaction_rec(1)  := p_resource_transaction_rec.POC_TRANS_ID;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(2)  := p_resource_transaction_rec.ORGN_CODE;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(3)  := p_resource_transaction_rec.DOC_TYPE;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(4)  := p_resource_transaction_rec.DOC_ID;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(5)  := p_resource_transaction_rec.LINE_ID;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(6)  := p_resource_transaction_rec.LINE_TYPE;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(7)  := p_resource_transaction_rec.RESOURCES;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(8)  := p_resource_transaction_rec.RESOURCE_USAGE;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(9)  := p_resource_transaction_rec.TRANS_UM;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(10) := p_resource_transaction_rec.TRANS_DATE;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(11) := p_resource_transaction_rec.COMPLETED_IND;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(12) := p_resource_transaction_rec.POSTED_IND;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(13) := p_resource_transaction_rec.REASON_CODE;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(14) := p_resource_transaction_rec.EVENT_ID;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(15) := p_resource_transaction_rec.INSTANCE_ID;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(16) := p_resource_transaction_rec.SEQUENCE_DEPENDENT_IND;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(17) := p_resource_transaction_rec.START_DATE;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(18) := p_resource_transaction_rec.END_DATE;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(19) := p_resource_transaction_rec.TEXT_CODE;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(20) := p_resource_transaction_rec.OVERRIDED_PROTECTED_IND;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(21) := p_resource_transaction_rec.ACTION_CODE;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(22) := p_resource_transaction_rec.TRANSACTION_NO;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(23) := p_resource_transaction_rec.DELETE_MARK;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(24) := p_resource_transaction_rec.ORGANIZATION_ID;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(25) := p_resource_transaction_rec.ATTRIBUTE_CATEGORY;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(26) := p_resource_transaction_rec.ATTRIBUTE1;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(27) := p_resource_transaction_rec.ATTRIBUTE2;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(28) := p_resource_transaction_rec.ATTRIBUTE3;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(29) := p_resource_transaction_rec.ATTRIBUTE4;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(30) := p_resource_transaction_rec.ATTRIBUTE5;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(31) := p_resource_transaction_rec.ATTRIBUTE6;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(32) := p_resource_transaction_rec.ATTRIBUTE7;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(33) := p_resource_transaction_rec.ATTRIBUTE8;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(34) := p_resource_transaction_rec.ATTRIBUTE9;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(35) := p_resource_transaction_rec.ATTRIBUTE10;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(36) := p_resource_transaction_rec.ATTRIBUTE11;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(37) := p_resource_transaction_rec.ATTRIBUTE12;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(38) := p_resource_transaction_rec.ATTRIBUTE13;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(39) := p_resource_transaction_rec.ATTRIBUTE14;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(40) := p_resource_transaction_rec.ATTRIBUTE15;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(41) := p_resource_transaction_rec.ATTRIBUTE16;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(42) := p_resource_transaction_rec.ATTRIBUTE17;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(43) := p_resource_transaction_rec.ATTRIBUTE18;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(44) := p_resource_transaction_rec.ATTRIBUTE19;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(45) := p_resource_transaction_rec.ATTRIBUTE20;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(46) := p_resource_transaction_rec.ATTRIBUTE21;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(47) := p_resource_transaction_rec.ATTRIBUTE22;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(48) := p_resource_transaction_rec.ATTRIBUTE23;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(49) := p_resource_transaction_rec.ATTRIBUTE24;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(50) := p_resource_transaction_rec.ATTRIBUTE25;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(51) := p_resource_transaction_rec.ATTRIBUTE26;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(52) := p_resource_transaction_rec.ATTRIBUTE27;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(53) := p_resource_transaction_rec.ATTRIBUTE28;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(54) := p_resource_transaction_rec.ATTRIBUTE29;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(55) := p_resource_transaction_rec.ATTRIBUTE30;
x_resource_transaction_rec.extend;
x_resource_transaction_rec(56) := p_resource_transaction_rec.REASON_ID;

END get_resource_transaction_arr;

procedure get_resource_transaction_rec
(
p_resource_transaction_rec IN fnd_table_of_varchar2_255
,x_resource_transaction_rec OUT NOCOPY GME_RESOURCE_TXNS_GTMP%ROWTYPE
)
AS
BEGIN
x_resource_transaction_rec.POC_TRANS_ID              := p_resource_transaction_rec(1);
x_resource_transaction_rec.ORGN_CODE                 := p_resource_transaction_rec(2);
x_resource_transaction_rec.DOC_TYPE                  := p_resource_transaction_rec(3);
x_resource_transaction_rec.DOC_ID                    := p_resource_transaction_rec(4);
x_resource_transaction_rec.LINE_ID                   := p_resource_transaction_rec(5);
x_resource_transaction_rec.LINE_TYPE                 := p_resource_transaction_rec(6);
x_resource_transaction_rec.RESOURCES                 := p_resource_transaction_rec(7);
x_resource_transaction_rec.RESOURCE_USAGE            := p_resource_transaction_rec(8);
x_resource_transaction_rec.TRANS_UM                  := p_resource_transaction_rec(9);
x_resource_transaction_rec.TRANS_DATE                := fnd_date.displaydt_to_date(p_resource_transaction_rec(10), FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE);
x_resource_transaction_rec.COMPLETED_IND             := p_resource_transaction_rec(11);
x_resource_transaction_rec.POSTED_IND                := p_resource_transaction_rec(12);
x_resource_transaction_rec.REASON_CODE               := p_resource_transaction_rec(13);
x_resource_transaction_rec.EVENT_ID                  := p_resource_transaction_rec(14);
x_resource_transaction_rec.INSTANCE_ID               := p_resource_transaction_rec(15);
x_resource_transaction_rec.SEQUENCE_DEPENDENT_IND    := p_resource_transaction_rec(16);
x_resource_transaction_rec.START_DATE                := fnd_date.displaydt_to_date(p_resource_transaction_rec(17), FND_TIMEZONES.GET_CLIENT_TIMEZONE_CODE);
x_resource_transaction_rec.END_DATE                  := fnd_date.displaydt_to_date(p_resource_transaction_rec(18), FND_TIMEZONES.GET_CLIENT_TIMEZONE_CODE);
x_resource_transaction_rec.TEXT_CODE                 := p_resource_transaction_rec(19);
x_resource_transaction_rec.OVERRIDED_PROTECTED_IND   := p_resource_transaction_rec(20);
x_resource_transaction_rec.ACTION_CODE               := p_resource_transaction_rec(21);
x_resource_transaction_rec.TRANSACTION_NO            := p_resource_transaction_rec(22);
x_resource_transaction_rec.DELETE_MARK               := p_resource_transaction_rec(23);
x_resource_transaction_rec.ORGANIZATION_ID           := p_resource_transaction_rec(24);
x_resource_transaction_rec.ATTRIBUTE_CATEGORY        := p_resource_transaction_rec(25);
x_resource_transaction_rec.ATTRIBUTE1                := p_resource_transaction_rec(26);
x_resource_transaction_rec.ATTRIBUTE2                := p_resource_transaction_rec(27);
x_resource_transaction_rec.ATTRIBUTE3                := p_resource_transaction_rec(28);
x_resource_transaction_rec.ATTRIBUTE4                := p_resource_transaction_rec(29);
x_resource_transaction_rec.ATTRIBUTE5                := p_resource_transaction_rec(30);
x_resource_transaction_rec.ATTRIBUTE6                := p_resource_transaction_rec(31);
x_resource_transaction_rec.ATTRIBUTE7                := p_resource_transaction_rec(32);
x_resource_transaction_rec.ATTRIBUTE8                := p_resource_transaction_rec(33);
x_resource_transaction_rec.ATTRIBUTE9                := p_resource_transaction_rec(34);
x_resource_transaction_rec.ATTRIBUTE10               := p_resource_transaction_rec(35);
x_resource_transaction_rec.ATTRIBUTE11               := p_resource_transaction_rec(36);
x_resource_transaction_rec.ATTRIBUTE12               := p_resource_transaction_rec(37);
x_resource_transaction_rec.ATTRIBUTE13               := p_resource_transaction_rec(38);
x_resource_transaction_rec.ATTRIBUTE14               := p_resource_transaction_rec(39);
x_resource_transaction_rec.ATTRIBUTE15               := p_resource_transaction_rec(40);
x_resource_transaction_rec.ATTRIBUTE16               := p_resource_transaction_rec(41);
x_resource_transaction_rec.ATTRIBUTE17               := p_resource_transaction_rec(42);
x_resource_transaction_rec.ATTRIBUTE18               := p_resource_transaction_rec(43);
x_resource_transaction_rec.ATTRIBUTE19               := p_resource_transaction_rec(44);
x_resource_transaction_rec.ATTRIBUTE20               := p_resource_transaction_rec(45);
x_resource_transaction_rec.ATTRIBUTE21               := p_resource_transaction_rec(46);
x_resource_transaction_rec.ATTRIBUTE22               := p_resource_transaction_rec(47);
x_resource_transaction_rec.ATTRIBUTE23               := p_resource_transaction_rec(48);
x_resource_transaction_rec.ATTRIBUTE24               := p_resource_transaction_rec(49);
x_resource_transaction_rec.ATTRIBUTE25               := p_resource_transaction_rec(50);
x_resource_transaction_rec.ATTRIBUTE26               := p_resource_transaction_rec(51);
x_resource_transaction_rec.ATTRIBUTE27               := p_resource_transaction_rec(52);
x_resource_transaction_rec.ATTRIBUTE28               := p_resource_transaction_rec(53);
x_resource_transaction_rec.ATTRIBUTE29               := p_resource_transaction_rec(54);
x_resource_transaction_rec.ATTRIBUTE30               := p_resource_transaction_rec(55);
x_resource_transaction_rec.REASON_ID                 := p_resource_transaction_rec(56);

END get_resource_transaction_rec;

procedure create_resource_transaction (
p_resource_transaction_rec IN fnd_table_of_varchar2_255
,x_resource_transaction_rec OUT NOCOPY fnd_table_of_varchar2_255
,x_return_status	   OUT NOCOPY VARCHAR2
,x_message_count           OUT NOCOPY NUMBER
,x_message_data            OUT NOCOPY VARCHAR2
)
AS
l_resource_transaction_rec_in gme_resource_txns_gtmp%rowtype;
l_resource_transaction_rec_out gme_resource_txns_gtmp%rowtype;
BEGIN
	get_resource_transaction_rec(p_resource_transaction_rec, l_resource_transaction_rec_in);
	/*
	gme_resource_engine_pvt.create_resource_trans (
		p_tran_rec => l_resource_transaction_rec_in,
		x_tran_rec => l_resource_transaction_rec_out,
		x_return_status => x_return_status);
 	 */
	gme_api_grp.create_resource_txn (
		p_rsrc_txn_gtmp_rec => l_resource_transaction_rec_in,
		x_rsrc_txn_gtmp_rec => l_resource_transaction_rec_out,
		x_return_status => x_return_status);

	IF (x_return_status = fnd_api.g_ret_sts_success) then
		get_resource_transaction_arr(l_resource_transaction_rec_out, x_resource_transaction_rec);
	end if;
	FND_MSG_PUB.Count_And_Get (p_count => x_message_count, p_data => x_message_data);
END create_resource_transaction;

procedure update_resource_transaction (
p_resource_transaction_rec IN fnd_table_of_varchar2_255
,x_return_status	   OUT NOCOPY VARCHAR2
,x_message_count           OUT NOCOPY NUMBER
,x_message_data            OUT NOCOPY VARCHAR2
)
AS
l_resource_transaction_rec_in gme_resource_txns_gtmp%rowtype;
BEGIN
	get_resource_transaction_rec(p_resource_transaction_rec, l_resource_transaction_rec_in);
	/*
	gme_resource_engine_pvt.update_resource_trans (
		p_tran_rec => l_resource_transaction_rec_in,
		x_return_status => x_return_status);
	*/
	gme_api_grp.update_resource_txn (
		p_rsrc_txn_gtmp_rec => l_resource_transaction_rec_in,
		x_return_status => x_return_status);
	FND_MSG_PUB.Count_And_Get (p_count => x_message_count, p_data => x_message_data);
END update_resource_transaction;

procedure delete_resource_transaction (
p_resource_transaction_rec IN fnd_table_of_varchar2_255
,x_return_status	   OUT NOCOPY VARCHAR2
,x_message_count           OUT NOCOPY NUMBER
,x_message_data            OUT NOCOPY VARCHAR2
)
AS
l_resource_transaction_rec_in gme_resource_txns_gtmp%rowtype;
BEGIN
	get_resource_transaction_rec(p_resource_transaction_rec, l_resource_transaction_rec_in);
	/*
	gme_resource_engine_pvt.delete_resource_trans (
		p_tran_rec => l_resource_transaction_rec_in,
		x_return_status => x_return_status);
	*/
	gme_api_grp.delete_resource_txn (
		p_rsrc_txn_gtmp_rec => l_resource_transaction_rec_in,
                x_return_status => x_return_status);

	FND_MSG_PUB.Count_And_Get (p_count => x_message_count, p_data => x_message_data);
END delete_resource_transaction;

procedure setup_resource_transaction(
p_org_id 		NUMBER,
p_org_code		VARCHAR2,
p_batch_id		NUMBER,
x_return_status		OUT NOCOPY VARCHAR2,
x_message_count		OUT NOCOPY NUMBER,
x_message_data		OUT NOCOPY VARCHAR2
) AS
l_batch_record		gme_batch_header%rowtype;
l_rsrc_row_count	number;
BEGIN

	if (gme_common_pvt.setup(p_org_id => p_org_id, p_org_code => p_org_code)) then
		x_return_status := 'S';
	else
		x_return_status := 'E';
	end if;
	select * into l_batch_record from gme_batch_header where batch_id = p_batch_id;
	gme_trans_engine_util.load_rsrc_trans (p_batch_row =>l_batch_record, x_rsc_row_count => l_rsrc_row_count, x_return_status => x_return_status);
	FND_MSG_PUB.Count_And_Get (p_count => x_message_count, p_data => x_message_data);
END setup_resource_transaction;

procedure update_process_parameter
(
p_batch_no              IN              VARCHAR2
,p_org_code              IN              VARCHAR2
,p_validate_flexfields   IN              VARCHAR2
,p_batchstep_no          IN              NUMBER
,p_activity              IN              VARCHAR2
,p_parameter             IN              VARCHAR2
,p_process_param_rec     IN              fnd_table_of_varchar2_255
,x_process_param_rec     OUT NOCOPY      fnd_table_of_varchar2_255
,x_return_status         OUT NOCOPY      VARCHAR2
,x_message_count         OUT NOCOPY      NUMBER
,x_message_data          OUT NOCOPY      VARCHAR2
) AS

l_process_param_rec_in gme_process_parameters%rowtype;
l_process_param_rec_out gme_process_parameters%rowtype;

BEGIN


l_process_param_rec_in.PROCESS_PARAM_ID       := p_process_param_rec(1);
l_process_param_rec_in.BATCH_ID               := p_process_param_rec(2);
l_process_param_rec_in.BATCHSTEP_ID           := p_process_param_rec(3);
l_process_param_rec_in.BATCHSTEP_ACTIVITY_ID  := p_process_param_rec(4);
l_process_param_rec_in.BATCHSTEP_RESOURCE_ID  := p_process_param_rec(5);
l_process_param_rec_in.RESOURCES              := p_process_param_rec(6);
l_process_param_rec_in.PARAMETER_ID           := p_process_param_rec(7);
l_process_param_rec_in.TARGET_VALUE           := p_process_param_rec(8);
l_process_param_rec_in.MINIMUM_VALUE          := p_process_param_rec(9);
l_process_param_rec_in.MAXIMUM_VALUE          := p_process_param_rec(10);
l_process_param_rec_in.PARAMETER_UOM          := p_process_param_rec(11);
l_process_param_rec_in.ATTRIBUTE_CATEGORY     := p_process_param_rec(12);
l_process_param_rec_in.ATTRIBUTE1             := p_process_param_rec(13);
l_process_param_rec_in.ATTRIBUTE2             := p_process_param_rec(14);
l_process_param_rec_in.ATTRIBUTE3             := p_process_param_rec(15);
l_process_param_rec_in.ATTRIBUTE4             := p_process_param_rec(16);
l_process_param_rec_in.ATTRIBUTE5             := p_process_param_rec(17);
l_process_param_rec_in.ATTRIBUTE6             := p_process_param_rec(18);
l_process_param_rec_in.ATTRIBUTE7             := p_process_param_rec(19);
l_process_param_rec_in.ATTRIBUTE8             := p_process_param_rec(20);
l_process_param_rec_in.ATTRIBUTE9             := p_process_param_rec(21);
l_process_param_rec_in.ATTRIBUTE10            := p_process_param_rec(22);
l_process_param_rec_in.ATTRIBUTE11            := p_process_param_rec(23);
l_process_param_rec_in.ATTRIBUTE12            := p_process_param_rec(24);
l_process_param_rec_in.ATTRIBUTE13            := p_process_param_rec(25);
l_process_param_rec_in.ATTRIBUTE14            := p_process_param_rec(26);
l_process_param_rec_in.ATTRIBUTE15            := p_process_param_rec(27);
l_process_param_rec_in.ATTRIBUTE16            := p_process_param_rec(28);
l_process_param_rec_in.ATTRIBUTE17            := p_process_param_rec(29);
l_process_param_rec_in.ATTRIBUTE18            := p_process_param_rec(30);
l_process_param_rec_in.ATTRIBUTE19            := p_process_param_rec(31);
l_process_param_rec_in.ATTRIBUTE20            := p_process_param_rec(32);
l_process_param_rec_in.ATTRIBUTE21            := p_process_param_rec(33);
l_process_param_rec_in.ATTRIBUTE22            := p_process_param_rec(34);
l_process_param_rec_in.ATTRIBUTE23            := p_process_param_rec(35);
l_process_param_rec_in.ATTRIBUTE24            := p_process_param_rec(36);
l_process_param_rec_in.ATTRIBUTE25            := p_process_param_rec(37);
l_process_param_rec_in.ATTRIBUTE26            := p_process_param_rec(38);
l_process_param_rec_in.ATTRIBUTE27            := p_process_param_rec(39);
l_process_param_rec_in.ATTRIBUTE28            := p_process_param_rec(40);
l_process_param_rec_in.ATTRIBUTE29            := p_process_param_rec(41);
l_process_param_rec_in.ATTRIBUTE30            := p_process_param_rec(42);
l_process_param_rec_in.CREATED_BY             := p_process_param_rec(43);
l_process_param_rec_in.CREATION_DATE          := fnd_date.displaydt_to_date(p_process_param_rec(44), FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE);
l_process_param_rec_in.LAST_UPDATED_BY        := p_process_param_rec(45);
l_process_param_rec_in.LAST_UPDATE_LOGIN      := p_process_param_rec(46);
l_process_param_rec_in.LAST_UPDATE_DATE       := fnd_date.displaydt_to_date(p_process_param_rec(47), FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE);
l_process_param_rec_in.ACTUAL_VALUE           := p_process_param_rec(48);
l_process_param_rec_in.DEVICE_ID              := p_process_param_rec(49);

gme_api_pub.update_process_parameter
(
x_message_count     => x_message_count
,x_message_list     => x_message_data
,x_return_status    => x_return_status
,p_batch_no         => p_batch_no
,p_org_code         => p_org_code
,p_validate_flexfields => p_validate_flexfields
,p_batchstep_no     => p_batchstep_no
,p_activity         => p_activity
,p_parameter        => p_parameter
,p_process_param_rec  => l_process_param_rec_in
,x_process_param_rec  => l_process_param_rec_out
);

x_process_param_rec := new fnd_table_of_varchar2_255();

x_process_param_rec.extend;
x_process_param_rec(1) := l_process_param_rec_out.PROCESS_PARAM_ID       ;
x_process_param_rec.extend;
x_process_param_rec(2) := l_process_param_rec_out.BATCH_ID               ;
x_process_param_rec.extend;
x_process_param_rec(3) := l_process_param_rec_out.BATCHSTEP_ID           ;
x_process_param_rec.extend;
x_process_param_rec(4) := l_process_param_rec_out.BATCHSTEP_ACTIVITY_ID  ;
x_process_param_rec.extend;
x_process_param_rec(5) := l_process_param_rec_out.BATCHSTEP_RESOURCE_ID  ;
x_process_param_rec.extend;
x_process_param_rec(6) := l_process_param_rec_out.RESOURCES              ;
x_process_param_rec.extend;
x_process_param_rec(7) := l_process_param_rec_out.PARAMETER_ID           ;
x_process_param_rec.extend;
x_process_param_rec(8) := l_process_param_rec_out.TARGET_VALUE           ;
x_process_param_rec.extend;
x_process_param_rec(9) := l_process_param_rec_out.MINIMUM_VALUE          ;
x_process_param_rec.extend;
x_process_param_rec(10) := l_process_param_rec_out.MAXIMUM_VALUE         ;
x_process_param_rec.extend;
x_process_param_rec(11) := l_process_param_rec_out.PARAMETER_UOM         ;
x_process_param_rec.extend;
x_process_param_rec(12) := l_process_param_rec_out.ATTRIBUTE_CATEGORY    ;
x_process_param_rec.extend;
x_process_param_rec(13) := l_process_param_rec_out.ATTRIBUTE1            ;
x_process_param_rec.extend;
x_process_param_rec(14) := l_process_param_rec_out.ATTRIBUTE2            ;
x_process_param_rec.extend;
x_process_param_rec(15) := l_process_param_rec_out.ATTRIBUTE3            ;
x_process_param_rec.extend;
x_process_param_rec(16) := l_process_param_rec_out.ATTRIBUTE4            ;
x_process_param_rec.extend;
x_process_param_rec(17) := l_process_param_rec_out.ATTRIBUTE5            ;
x_process_param_rec.extend;
x_process_param_rec(18) := l_process_param_rec_out.ATTRIBUTE6            ;
x_process_param_rec.extend;
x_process_param_rec(19) := l_process_param_rec_out.ATTRIBUTE7            ;
x_process_param_rec.extend;
x_process_param_rec(20) := l_process_param_rec_out.ATTRIBUTE8            ;
x_process_param_rec.extend;
x_process_param_rec(21) := l_process_param_rec_out.ATTRIBUTE9            ;
x_process_param_rec.extend;
x_process_param_rec(22) := l_process_param_rec_out.ATTRIBUTE10           ;
x_process_param_rec.extend;
x_process_param_rec(23) := l_process_param_rec_out.ATTRIBUTE11           ;
x_process_param_rec.extend;
x_process_param_rec(24) := l_process_param_rec_out.ATTRIBUTE12           ;
x_process_param_rec.extend;
x_process_param_rec(25) := l_process_param_rec_out.ATTRIBUTE13           ;
x_process_param_rec.extend;
x_process_param_rec(26) := l_process_param_rec_out.ATTRIBUTE14           ;
x_process_param_rec.extend;
x_process_param_rec(27) := l_process_param_rec_out.ATTRIBUTE15           ;
x_process_param_rec.extend;
x_process_param_rec(28) := l_process_param_rec_out.ATTRIBUTE16           ;
x_process_param_rec.extend;
x_process_param_rec(29) := l_process_param_rec_out.ATTRIBUTE17           ;
x_process_param_rec.extend;
x_process_param_rec(30) := l_process_param_rec_out.ATTRIBUTE18           ;
x_process_param_rec.extend;
x_process_param_rec(31) := l_process_param_rec_out.ATTRIBUTE19           ;
x_process_param_rec.extend;
x_process_param_rec(32) := l_process_param_rec_out.ATTRIBUTE20           ;
x_process_param_rec.extend;
x_process_param_rec(33) := l_process_param_rec_out.ATTRIBUTE21           ;
x_process_param_rec.extend;
x_process_param_rec(34) := l_process_param_rec_out.ATTRIBUTE22           ;
x_process_param_rec.extend;
x_process_param_rec(35) := l_process_param_rec_out.ATTRIBUTE23           ;
x_process_param_rec.extend;
x_process_param_rec(36) := l_process_param_rec_out.ATTRIBUTE24           ;
x_process_param_rec.extend;
x_process_param_rec(37) := l_process_param_rec_out.ATTRIBUTE25           ;
x_process_param_rec.extend;
x_process_param_rec(38) := l_process_param_rec_out.ATTRIBUTE26           ;
x_process_param_rec.extend;
x_process_param_rec(39) := l_process_param_rec_out.ATTRIBUTE27           ;
x_process_param_rec.extend;
x_process_param_rec(40) := l_process_param_rec_out.ATTRIBUTE28           ;
x_process_param_rec.extend;
x_process_param_rec(41) := l_process_param_rec_out.ATTRIBUTE29           ;
x_process_param_rec.extend;
x_process_param_rec(42) := l_process_param_rec_out.ATTRIBUTE30           ;
x_process_param_rec.extend;
x_process_param_rec(43) := l_process_param_rec_out.CREATED_BY            ;
x_process_param_rec.extend;
x_process_param_rec(44) := l_process_param_rec_out.CREATION_DATE         ;
x_process_param_rec.extend;
x_process_param_rec(45) := l_process_param_rec_out.LAST_UPDATED_BY       ;
x_process_param_rec.extend;
x_process_param_rec(46) := l_process_param_rec_out.LAST_UPDATE_LOGIN     ;
x_process_param_rec.extend;
x_process_param_rec(47) := l_process_param_rec_out.LAST_UPDATE_DATE      ;
x_process_param_rec.extend;
x_process_param_rec(48) := l_process_param_rec_out.ACTUAL_VALUE          ;
x_process_param_rec.extend;
x_process_param_rec(49) := l_process_param_rec_out.DEVICE_ID             ;


FND_MSG_PUB.Count_And_Get (p_count => x_message_count, p_data => x_message_data);

END update_process_parameter;

procedure save_batch (
p_table			   in number
,x_return_status           OUT NOCOPY VARCHAR2
,x_message_count           OUT NOCOPY NUMBER
,x_message_data            OUT NOCOPY VARCHAR2
) is
begin
	gme_api_pub.save_batch (
		p_header_id => null,
		p_table => p_table,
		p_commit => fnd_api.g_false,
		x_return_status => x_return_status,
		p_clear_qty_cache =>FND_API.g_true
	);
	FND_MSG_PUB.Count_And_Get (p_count => x_message_count, p_data => x_message_data);
end save_batch;


procedure get_material_transactions(
p_organization_id          IN NUMBER
,p_batch_id                IN NUMBER
,p_material_detail_id      IN NUMBER
,x_mmt_cur                 OUT NOCOPY gme_api_grp.g_gmo_txns
,x_return_status           OUT NOCOPY VARCHAR2
,x_message_count           OUT NOCOPY NUMBER
,x_message_data            OUT NOCOPY VARCHAR2
)
is

begin
/*
	open x_mmt_cur for
	SELECT
		mmt.transaction_id, mmt.subinventory_code, mmt.transaction_quantity, mmt.transaction_uom,
		mmt.secondary_transaction_quantity, mmt.secondary_uom_code, mtlt.lot_number, mmt.revision,
		mmt.locator_id, (select concatenated_segments
					from mtl_item_locations_kfv
					where organization_id = mmt.organization_id
					and subinventory_code = mmt.subinventory_code
					and inventory_location_id=mmt.locator_id) locator_code,
		mmt.TRANSACTION_TYPE_ID
	FROM mtl_material_transactions mmt, mtl_transaction_lot_numbers mtlt
	WHERE mmt.transaction_source_id = p_batch_id
	AND mmt.trx_source_line_id = p_material_detail_id
	AND mmt.transaction_source_type_id = 5
	AND NOT EXISTS (SELECT transaction_id1
					FROM gme_transaction_pairs
					WHERE transaction_id1 = mmt.transaction_id
					AND pair_type = 1)
	and mtlt.transaction_id (+) = mmt.transaction_id
	and mmt.organization_id = p_organization_id;
	x_return_status := 'S';

*/
	gme_api_grp.get_mat_trans
	(
		p_organization_id => p_organization_id
		,p_mat_det_id => p_material_detail_id
		,p_batch_id => p_batch_id
		,x_txns_cur => x_mmt_cur
		,x_return_status => x_return_status
	);
	FND_MSG_PUB.Count_And_Get (p_count => x_message_count, p_data => x_message_data);

end get_material_transactions;

procedure get_lot_transactions(
p_transaction_id           IN NUMBER
,x_lt_cur                  OUT NOCOPY gme_api_grp.g_gmo_lot_txns
,x_return_status           OUT NOCOPY VARCHAR2
,x_message_count           OUT NOCOPY NUMBER
,x_message_data            OUT NOCOPY VARCHAR2
)
IS
begin
	gme_api_grp.get_lot_trans
        (
                p_transaction_id => p_transaction_id
                ,x_lot_txns_cur => x_lt_cur
                ,x_return_status => x_return_status
        );
        FND_MSG_PUB.Count_And_Get (p_count => x_message_count, p_data => x_message_data);
end get_lot_transactions;

procedure get_material_reservations(
p_organization_id          IN NUMBER
,p_batch_id                IN NUMBER
,p_material_detail_id      IN NUMBER
,x_res_cur                 OUT NOCOPY gme_api_grp.g_gmo_resvns
,x_return_status           OUT NOCOPY VARCHAR2
,x_message_count           OUT NOCOPY NUMBER
,x_message_data            OUT NOCOPY VARCHAR2
)
IS
begin
	/*
	open x_res_cur for
	SELECT
		reservation_id, subinventory_code, primary_reservation_quantity, reservation_uom_code,
		secondary_reservation_quantity, secondary_uom_code, lot_number, revision,
		locator_id, (select concatenated_segments
					 from mtl_item_locations_kfv
					 where organization_id = mr.organization_id
					 and subinventory_code = mr.subinventory_code
					 and inventory_location_id=mr.locator_id)
		FROM mtl_reservations mr
		WHERE organization_id = p_organization_id
		AND demand_source_type_id = 5
		AND demand_source_header_id = p_batch_id
		AND demand_source_line_id = p_material_detail_id
		AND NOT EXISTS (SELECT 1
				FROM mtl_material_transactions_temp
				WHERE reservation_id = mr.reservation_id);
	x_return_status := 'S';
	*/
	gme_api_grp.get_mat_resvns
	(
		p_organization_id => p_organization_id
                ,p_mat_det_id => p_material_detail_id
                ,p_batch_id => p_batch_id
                ,x_resvns_cur => x_res_cur
		,x_return_status => x_return_status
        );

	FND_MSG_PUB.Count_And_Get (p_count => x_message_count, p_data => x_message_data);

end get_material_reservations;

procedure get_material_pplots(
p_organization_id          IN NUMBER
,p_batch_id                IN NUMBER
,p_material_detail_id      IN NUMBER
,x_pplot_cur               OUT NOCOPY gme_api_grp.g_gmo_pplots
,x_return_status           OUT NOCOPY VARCHAR2
,x_message_count           OUT NOCOPY NUMBER
,x_message_data            OUT NOCOPY VARCHAR2
)
IS
begin
	gme_api_grp.get_mat_pplots
        (
                p_mat_det_id => p_material_detail_id
                ,x_pplot_cur => x_pplot_cur
                ,x_return_status => x_return_status
        );

        FND_MSG_PUB.Count_And_Get (p_count => x_message_count, p_data => x_message_data);
end get_material_pplots;


procedure convert_um (
p_organization_id          IN NUMBER
,p_inventory_item_id       IN NUMBER
,p_lot_number              IN VARCHAR2
,p_from_qty                IN NUMBER
,p_from_um                 IN VARCHAR2
,p_to_um                   IN VARCHAR2
,x_to_qty                  OUT NOCOPY NUMBER
,x_return_status           OUT NOCOPY VARCHAR2
,x_message_count           OUT NOCOPY NUMBER
,x_message_data            OUT NOCOPY VARCHAR2
)
is
uom_conversion_err exception;
begin
	x_to_qty := inv_convert.inv_um_convert(
			p_inventory_item_id,
                        p_lot_number,
                        p_organization_id,
                        5,
                        p_from_qty,
                        p_from_um,
                        p_to_um,
                        null,
                        null
                    );
	if (x_to_qty = -99999) THEN
		RAISE uom_conversion_err;
        END IF;

	x_return_status := fnd_api.g_ret_sts_success;
        FND_MSG_PUB.Count_And_Get (p_count => x_message_count, p_data => x_message_data);
exception
	WHEN uom_conversion_err THEN
                x_return_status:= fnd_api.g_ret_sts_error;
                FND_MESSAGE.SET_NAME('GMO','GMO_UM_CONVERT_ERR');
                FND_MESSAGE.SET_TOKEN('FROM_UOM',p_from_um);
                FND_MESSAGE.SET_TOKEN('TO_UOM',p_to_um);
                if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_vbatch_task_pvt.convert_um', FALSE);
                end if;
                FND_MSG_PUB.ADD;
                FND_MSG_PUB.Count_And_Get (p_count => x_message_count, p_data => x_message_data);
        WHEN OTHERS THEN
                x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
                FND_MESSAGE.SET_NAME('GMO','GMO_VBATCH_UNEXPECTED_DB_ERR');
                FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
                FND_MESSAGE.SET_TOKEN('ERROR_CODE',SQLCODE);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_vbatch_task_pvt.convert_um', FALSE);
                end if;
                FND_MSG_PUB.ADD;
                FND_MSG_PUB.Count_And_Get (p_count => x_message_count, p_data => x_message_data);

end convert_um;

procedure qty_within_deviation (
p_organization_id          IN NUMBER
,p_inventory_item_id       IN NUMBER
,p_lot_number              IN NUMBER
,p_qty                     IN NUMBER
,p_um                      IN VARCHAR2
,p_sec_qty                 IN NUMBER
,p_sec_um                  IN VARCHAR2
,x_return_status           OUT NOCOPY VARCHAR2
,x_message_count           OUT NOCOPY NUMBER
,x_message_data            OUT NOCOPY VARCHAR2
)
IS

DEV_LOW_ERROR         EXCEPTION;
DEV_HIGH_ERROR        EXCEPTION;
INVALID_ITEM          EXCEPTION;
INCORRECT_FIXED_VALUE EXCEPTION;
INVALID_UOM_CONV      EXCEPTION;

l_is_valid      NUMBER(1);
l_msg_index_out NUMBER;

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Validate the quantities within deviation
    l_is_valid := INV_CONVERT.within_deviation(
                          p_organization_id => p_organization_id
                        , p_inventory_item_id  => p_inventory_item_id
                        , p_lot_number         => p_lot_number
                        , p_precision          => 5
                        , p_quantity           => ABS(p_qty)
                        , p_uom_code1          => p_um
                        , p_quantity2          => ABS(p_sec_qty)
                        , p_uom_code2           => p_sec_um);
     IF (l_is_valid = 0)
     THEN

       x_return_status := FND_API.G_RET_STS_ERROR;

       FND_MSG_PUB.Get(
                        p_msg_index     => 1,
                        p_data          => x_message_data,
                        p_encoded       => FND_API.G_FALSE,
                        p_msg_index_out => l_msg_index_out);
     END IF;

EXCEPTION
	WHEN INVALID_ITEM THEN
		x_return_status:= fnd_api.g_ret_sts_error;
		FND_MESSAGE.SET_NAME('INV','INV_INVALID_ITEM');
		FND_MSG_PUB.ADD;
		FND_MSG_PUB.Count_And_Get (p_count => x_message_count, p_data => x_message_data);
	WHEN INCORRECT_FIXED_VALUE THEN
		x_return_status:= fnd_api.g_ret_sts_error;
		FND_MESSAGE.SET_NAME('INV','INV_INCORRECT_FIXED_VALUE');
		FND_MSG_PUB.ADD;
		FND_MSG_PUB.Count_And_Get (p_count => x_message_count, p_data => x_message_data);
	WHEN INVALID_UOM_CONV THEN
		x_return_status:= fnd_api.g_ret_sts_error;
		FND_MESSAGE.SET_NAME('INV','INV_INVALID_UOM_CONV');
		FND_MESSAGE.SET_TOKEN ('VALUE1',p_um);
		FND_MESSAGE.SET_TOKEN ('VALUE2',p_sec_um);
		FND_MSG_PUB.ADD;
		FND_MSG_PUB.Count_And_Get (p_count => x_message_count, p_data => x_message_data);
	WHEN DEV_LOW_ERROR THEN
		x_return_status:= fnd_api.g_ret_sts_error;
		FND_MESSAGE.SET_NAME('INV','INV_DEVIATION_LO_ERR');
		FND_MSG_PUB.ADD;
		FND_MSG_PUB.Count_And_Get (p_count => x_message_count, p_data => x_message_data);
	WHEN DEV_HIGH_ERROR THEN
		x_return_status:= fnd_api.g_ret_sts_error;
		FND_MESSAGE.SET_NAME('INV','INV_DEVIATION_HI_ERR');
		FND_MSG_PUB.ADD;
		FND_MSG_PUB.Count_And_Get (p_count => x_message_count, p_data => x_message_data);
	WHEN OTHERS THEN
		x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
		FND_MESSAGE.SET_NAME('GMO','GMO_VBATCH_UNEXPECTED_DB_ERR');
		FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
		FND_MESSAGE.SET_TOKEN('ERROR_CODE',SQLCODE);
		if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_vbatch_task_pvt.qty_within_deviation', FALSE);
		end if;
		FND_MSG_PUB.ADD;
		FND_MSG_PUB.Count_And_Get (p_count => x_message_count, p_data => x_message_data);
END qty_within_deviation;

procedure get_dispense_um(
p_material_detail_id       IN NUMBER
,x_dispense_um             OUT NOCOPY VARCHAR2
,x_return_status           OUT NOCOPY VARCHAR2
,x_message_count           OUT NOCOPY NUMBER
,x_message_data            OUT NOCOPY VARCHAR2
)

is
l_instr_def_key VARCHAR2(40);
l_dispense_config_row GMO_DISPENSE_CONFIG%ROWTYPE;
DISP_NOT_REQ_EXCEPTION exception;
begin
	GMO_DISPENSE_SETUP_PVT.GET_DISPENSE_CONFIG_INST(P_ENTITY_NAME=> GMO_DISPENSE_GRP.G_MATERIAL_LINE_ENTITY,
                             P_ENTITY_KEY=> p_material_detail_id ,
                             X_DISPENSE_CONFIG => l_dispense_config_row,
                             X_INSTRUCTION_DEFINITION_KEY  => l_instr_def_key);
	if(l_dispense_config_row.config_id is null) then
        	RAISE DISP_NOT_REQ_EXCEPTION;
    	end if;
    	x_dispense_um := l_dispense_config_row.dispense_uom;
	x_return_status := fnd_api.g_ret_sts_success;
        FND_MSG_PUB.Count_And_Get (p_count => x_message_count, p_data => x_message_data);
exception
	when DISP_NOT_REQ_EXCEPTION then
	        x_return_status:= fnd_api.g_ret_sts_error;
                FND_MESSAGE.SET_NAME('GMO','GMO_DISP_DISPENSE_NOT_REQ_ERR');
                if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_vbatch_task_pvt.get_dispense_um', FALSE);
                end if;
                FND_MSG_PUB.ADD;
                FND_MSG_PUB.Count_And_Get (p_count => x_message_count, p_data => x_message_data);
        WHEN OTHERS THEN
                x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
                FND_MESSAGE.SET_NAME('GMO','GMO_VBATCH_UNEXPECTED_DB_ERR');
                FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
                FND_MESSAGE.SET_TOKEN('ERROR_CODE',SQLCODE);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_vbatch_task_pvt.get_dispense_um', FALSE);
                end if;
                FND_MSG_PUB.ADD;
                FND_MSG_PUB.Count_And_Get (p_count => x_message_count, p_data => x_message_data);

end get_dispense_um;

procedure relieve_reservation(
p_reservation_id          IN NUMBER
,p_prim_relieve_quantity  IN NUMBER
,x_return_status           OUT NOCOPY VARCHAR2
,x_message_count           OUT NOCOPY NUMBER
,x_message_data            OUT NOCOPY VARCHAR2
)
IS

BEGIN

	gme_reservations_pvt.relieve_reservation (
		p_reservation_id => p_reservation_id
		,p_prim_relieve_qty => p_prim_relieve_quantity
		,x_return_status => x_return_status
	);

	FND_MSG_PUB.Count_And_Get (p_count => x_message_count, p_data => x_message_data);

EXCEPTION
        WHEN OTHERS THEN
                x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
                FND_MESSAGE.SET_NAME('GMO','GMO_VBATCH_UNEXPECTED_DB_ERR');
                FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
                FND_MESSAGE.SET_TOKEN('ERROR_CODE',SQLCODE);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_vbatch_task_pvt.get_resource_txn_end_date', FALSE);
                end if;
                FND_MSG_PUB.ADD;
                FND_MSG_PUB.Count_And_Get (p_count => x_message_count, p_data => x_message_data);
END relieve_reservation;

procedure relieve_pending_lot(
p_pending_lot_id           IN  NUMBER
,p_quantity                IN  NUMBER
,p_secondary_quantity      IN  NUMBER
,x_return_status           OUT NOCOPY VARCHAR2
,x_message_count           OUT NOCOPY NUMBER
,x_message_data            OUT NOCOPY VARCHAR2
)
IS
BEGIN

	gme_pending_product_lots_pvt.relieve_pending_lot (
		p_pending_lot_id => p_pending_lot_id
		,p_quantity => p_quantity
		,p_secondary_quantity => p_secondary_quantity
		,x_return_status => x_return_status
	);

	FND_MSG_PUB.Count_And_Get (p_count => x_message_count, p_data => x_message_data);

EXCEPTION
        WHEN OTHERS THEN
                x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
                FND_MESSAGE.SET_NAME('GMO','GMO_VBATCH_UNEXPECTED_DB_ERR');
                FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
                FND_MESSAGE.SET_TOKEN('ERROR_CODE',SQLCODE);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_vbatch_task_pvt.relieve_pending_lot', FALSE);
                end if;
                FND_MSG_PUB.ADD;
                FND_MSG_PUB.Count_And_Get (p_count => x_message_count, p_data => x_message_data);
END relieve_pending_lot;


procedure create_material_transaction(
p_mtl_txn_rec              IN fnd_table_of_varchar2_255
,p_mtl_lot_rec             IN fnd_table_of_varchar2_255
,x_return_status           OUT NOCOPY VARCHAR2
,x_message_count           OUT NOCOPY NUMBER
,x_message_data            OUT NOCOPY VARCHAR2
)
IS

l_mtl_txn_rec 	mtl_transactions_interface%ROWTYPE;
l_mtl_lot_rec	mtl_transaction_lots_interface%ROWTYPE;
l_mtl_lot_tbl   gme_common_pvt.mtl_trans_lots_inter_tbl;

BEGIN
	l_mtl_txn_rec.TRANSACTION_INTERFACE_ID     := p_mtl_txn_rec(1);
	l_mtl_txn_rec.TRANSACTION_TYPE_ID          := p_mtl_txn_rec(2);
	l_mtl_txn_rec.REVISION                     := p_mtl_txn_rec(3);
	l_mtl_txn_rec.TRANSACTION_UOM              := p_mtl_txn_rec(4);
	l_mtl_txn_rec.TRANSACTION_DATE             := fnd_date.displaydt_to_date(p_mtl_txn_rec(5), FND_TIMEZONES.GET_CLIENT_TIMEZONE_CODE);
	l_mtl_txn_rec.SUBINVENTORY_CODE            := p_mtl_txn_rec(6);
	l_mtl_txn_rec.SECONDARY_UOM_CODE           := p_mtl_txn_rec(7);
	l_mtl_txn_rec.SECONDARY_TRANSACTION_QUANTITY := p_mtl_txn_rec(8);
	l_mtl_txn_rec.PRIMARY_QUANTITY             := p_mtl_txn_rec(9);
	l_mtl_txn_rec.TRANSACTION_QUANTITY         := p_mtl_txn_rec(10);
	l_mtl_txn_rec.ORGANIZATION_ID              := p_mtl_txn_rec(11);
	l_mtl_txn_rec.REASON_ID                    := p_mtl_txn_rec(12);
	l_mtl_txn_rec.TRANSACTION_ACTION_ID        := p_mtl_txn_rec(13);
	l_mtl_txn_rec.TRANSACTION_SOURCE_NAME      := p_mtl_txn_rec(14);
	l_mtl_txn_rec.TRX_SOURCE_LINE_ID           := p_mtl_txn_rec(15);
	l_mtl_txn_rec.LOCATOR_ID                   := p_mtl_txn_rec(16);
	l_mtl_txn_rec.INVENTORY_ITEM_ID            := p_mtl_txn_rec(17);
	l_mtl_txn_rec.TRANSACTION_REFERENCE        := p_mtl_txn_rec(18);
	l_mtl_txn_rec.TRANSACTION_SOURCE_ID        := p_mtl_txn_rec(19);

	if(p_mtl_lot_rec IS NOT NULL and p_mtl_lot_rec.count > 0) THEN
		l_mtl_lot_rec.TRANSACTION_QUANTITY                  := p_mtl_lot_rec(1);
		l_mtl_lot_rec.TRANSACTION_INTERFACE_ID              := p_mtl_lot_rec(2);
		l_mtl_lot_rec.SECONDARY_TRANSACTION_QUANTITY        := p_mtl_lot_rec(3);
		l_mtl_lot_rec.PRIMARY_QUANTITY                      := p_mtl_lot_rec(4);
		l_mtl_lot_rec.LOT_NUMBER                            := p_mtl_lot_rec(5);
		l_mtl_lot_tbl(1) := l_mtl_lot_rec;
	end if;

	gme_api_grp.create_material_txn(
		p_mmti_rec => l_mtl_txn_rec,
	    p_mmli_tbl => l_mtl_lot_tbl,
        x_return_status   => x_return_status
    );

	FND_MSG_PUB.Count_And_Get (p_count => x_message_count, p_data => x_message_data);

EXCEPTION
        WHEN OTHERS THEN
                x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
                FND_MESSAGE.SET_NAME('GMO','GMO_VBATCH_UNEXPECTED_DB_ERR');
                FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
                FND_MESSAGE.SET_TOKEN('ERROR_CODE',SQLCODE);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_vbatch_task_pvt.create_material_transaction', FALSE);
                end if;
                FND_MSG_PUB.ADD;
                FND_MSG_PUB.Count_And_Get (p_count => x_message_count, p_data => x_message_data);
END create_material_transaction;



procedure update_material_transaction(
p_mtl_txn_rec              IN fnd_table_of_varchar2_255
,p_mtl_lot_rec             IN fnd_table_of_varchar2_255
,x_return_status           OUT NOCOPY VARCHAR2
,x_message_count           OUT NOCOPY NUMBER
,x_message_data            OUT NOCOPY VARCHAR2
)
IS

l_mtl_txn_rec 	mtl_transactions_interface%ROWTYPE;
l_mtl_lot_rec	mtl_transaction_lots_interface%ROWTYPE;
l_mtl_lot_tbl   gme_common_pvt.mtl_trans_lots_inter_tbl;

BEGIN

	l_mtl_txn_rec.TRANSACTION_INTERFACE_ID     := p_mtl_txn_rec(1);
	l_mtl_txn_rec.TRANSACTION_TYPE_ID          := p_mtl_txn_rec(2);
	l_mtl_txn_rec.REVISION                     := p_mtl_txn_rec(3);
	l_mtl_txn_rec.TRANSACTION_UOM              := p_mtl_txn_rec(4);
	l_mtl_txn_rec.TRANSACTION_DATE             := fnd_date.displaydt_to_date(p_mtl_txn_rec(5), FND_TIMEZONES.GET_CLIENT_TIMEZONE_CODE);
	l_mtl_txn_rec.SUBINVENTORY_CODE            := p_mtl_txn_rec(6);
	l_mtl_txn_rec.SECONDARY_UOM_CODE           := p_mtl_txn_rec(7);
	l_mtl_txn_rec.SECONDARY_TRANSACTION_QUANTITY := p_mtl_txn_rec(8);
	l_mtl_txn_rec.PRIMARY_QUANTITY             := p_mtl_txn_rec(9);
	l_mtl_txn_rec.TRANSACTION_QUANTITY         := p_mtl_txn_rec(10);
	l_mtl_txn_rec.ORGANIZATION_ID              := p_mtl_txn_rec(11);
	l_mtl_txn_rec.REASON_ID                    := p_mtl_txn_rec(12);
	l_mtl_txn_rec.TRANSACTION_ACTION_ID        := p_mtl_txn_rec(13);
	l_mtl_txn_rec.TRANSACTION_SOURCE_NAME      := p_mtl_txn_rec(14);
	l_mtl_txn_rec.TRX_SOURCE_LINE_ID           := p_mtl_txn_rec(15);
	l_mtl_txn_rec.LOCATOR_ID                   := p_mtl_txn_rec(16);
	l_mtl_txn_rec.INVENTORY_ITEM_ID            := p_mtl_txn_rec(17);
	l_mtl_txn_rec.TRANSACTION_REFERENCE        := p_mtl_txn_rec(18);
	l_mtl_txn_rec.TRANSACTION_SOURCE_ID        := p_mtl_txn_rec(19);

	if(p_mtl_lot_rec IS NOT NULL and p_mtl_lot_rec.count > 0) THEN
		l_mtl_lot_rec.TRANSACTION_QUANTITY                  := p_mtl_lot_rec(1);
		l_mtl_lot_rec.TRANSACTION_INTERFACE_ID              := p_mtl_lot_rec(2);
		l_mtl_lot_rec.SECONDARY_TRANSACTION_QUANTITY        := p_mtl_lot_rec(3);
		l_mtl_lot_rec.PRIMARY_QUANTITY                      := p_mtl_lot_rec(4);
		l_mtl_lot_rec.LOT_NUMBER                            := p_mtl_lot_rec(5);
		l_mtl_lot_tbl(1) := l_mtl_lot_rec;
        end if;

	gme_api_grp.update_material_txn(
		p_transaction_id => l_mtl_txn_rec.TRANSACTION_INTERFACE_ID,
		p_mmti_rec => l_mtl_txn_rec,
	    p_mmli_tbl => l_mtl_lot_tbl,
        x_return_status   => x_return_status
	);

	FND_MSG_PUB.Count_And_Get (p_count => x_message_count, p_data => x_message_data);


EXCEPTION
        WHEN OTHERS THEN
                x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
                FND_MESSAGE.SET_NAME('GMO','GMO_VBATCH_UNEXPECTED_DB_ERR');
                FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
                FND_MESSAGE.SET_TOKEN('ERROR_CODE',SQLCODE);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_vbatch_task_pvt.update_material_transaction', FALSE);
                end if;
                FND_MSG_PUB.ADD;
                FND_MSG_PUB.Count_And_Get (p_count => x_message_count, p_data => x_message_data);
END update_material_transaction;


procedure delete_material_transaction(
p_mtl_txn_rec              IN fnd_table_of_varchar2_255
,p_mtl_lot_rec             IN fnd_table_of_varchar2_255
,x_return_status           OUT NOCOPY VARCHAR2
,x_message_count           OUT NOCOPY NUMBER
,x_message_data            OUT NOCOPY VARCHAR2
)
IS

l_mtl_txn_rec 	mtl_transactions_interface%ROWTYPE;
l_mtl_lot_rec	mtl_transaction_lots_interface%ROWTYPE;
l_mtl_lot_tbl   gme_common_pvt.mtl_trans_lots_inter_tbl;

BEGIN

	l_mtl_txn_rec.TRANSACTION_INTERFACE_ID     := p_mtl_txn_rec(1);
	l_mtl_txn_rec.TRANSACTION_TYPE_ID          := p_mtl_txn_rec(2);
	l_mtl_txn_rec.REVISION                     := p_mtl_txn_rec(3);
	l_mtl_txn_rec.TRANSACTION_UOM              := p_mtl_txn_rec(4);
	l_mtl_txn_rec.TRANSACTION_DATE             := fnd_date.displaydt_to_date(p_mtl_txn_rec(5), FND_TIMEZONES.GET_CLIENT_TIMEZONE_CODE);
	l_mtl_txn_rec.SUBINVENTORY_CODE            := p_mtl_txn_rec(6);
	l_mtl_txn_rec.SECONDARY_UOM_CODE           := p_mtl_txn_rec(7);
	l_mtl_txn_rec.SECONDARY_TRANSACTION_QUANTITY := p_mtl_txn_rec(8);
	l_mtl_txn_rec.PRIMARY_QUANTITY             := p_mtl_txn_rec(9);
	l_mtl_txn_rec.TRANSACTION_QUANTITY         := p_mtl_txn_rec(10);
	l_mtl_txn_rec.ORGANIZATION_ID              := p_mtl_txn_rec(11);
	l_mtl_txn_rec.REASON_ID                    := p_mtl_txn_rec(12);
	l_mtl_txn_rec.TRANSACTION_ACTION_ID        := p_mtl_txn_rec(13);
	l_mtl_txn_rec.TRANSACTION_SOURCE_NAME      := p_mtl_txn_rec(14);
	l_mtl_txn_rec.TRX_SOURCE_LINE_ID           := p_mtl_txn_rec(15);
	l_mtl_txn_rec.LOCATOR_ID                   := p_mtl_txn_rec(16);
	l_mtl_txn_rec.INVENTORY_ITEM_ID            := p_mtl_txn_rec(17);
	l_mtl_txn_rec.TRANSACTION_REFERENCE        := p_mtl_txn_rec(18);
	l_mtl_txn_rec.TRANSACTION_SOURCE_ID        := p_mtl_txn_rec(19);
	if(p_mtl_lot_rec IS NOT NULL and p_mtl_lot_rec.count > 0) THEN
		l_mtl_lot_rec.TRANSACTION_QUANTITY                  := p_mtl_lot_rec(1);
		l_mtl_lot_rec.TRANSACTION_INTERFACE_ID              := p_mtl_lot_rec(2);
		l_mtl_lot_rec.SECONDARY_TRANSACTION_QUANTITY        := p_mtl_lot_rec(3);
		l_mtl_lot_rec.PRIMARY_QUANTITY                      := p_mtl_lot_rec(4);
		l_mtl_lot_rec.LOT_NUMBER                            := p_mtl_lot_rec(5);

		l_mtl_lot_tbl(1) := l_mtl_lot_rec;
        end if;
	gme_api_grp.delete_material_txn(
		p_organization_id => l_mtl_txn_rec.ORGANIZATION_ID,
		p_transaction_id => l_mtl_txn_rec.TRANSACTION_INTERFACE_ID,
	        x_return_status   => x_return_status
	);

	FND_MSG_PUB.Count_And_Get (p_count => x_message_count, p_data => x_message_data);

EXCEPTION
        WHEN OTHERS THEN
                x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
                FND_MESSAGE.SET_NAME('GMO','GMO_VBATCH_UNEXPECTED_DB_ERR');
                FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
                FND_MESSAGE.SET_TOKEN('ERROR_CODE',SQLCODE);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_vbatch_task_pvt.delete_material_transaction', FALSE);
                end if;
                FND_MSG_PUB.ADD;
                FND_MSG_PUB.Count_And_Get (p_count => x_message_count, p_data => x_message_data);
END delete_material_transaction;

procedure create_lot(
p_lot_rec                  IN fnd_table_of_varchar2_255
,x_return_status           OUT NOCOPY VARCHAR2
,x_message_count           OUT NOCOPY NUMBER
,x_message_data            OUT NOCOPY VARCHAR2
)
IS
l_lot_rec mtl_lot_numbers%ROWTYPE;
l_char_tbl inv_lot_api_pub.char_tbl;
l_number_tbl inv_lot_api_pub.number_tbl;
l_date_tbl inv_lot_api_pub.date_tbl;
BEGIN
l_lot_rec.INVENTORY_ITEM_ID    := p_lot_rec(1);
l_lot_rec.ORGANIZATION_ID      := p_lot_rec(2);
l_lot_rec.LOT_NUMBER           := p_lot_rec(3);
if (p_lot_rec(4) is not null) then
	l_lot_rec.EXPIRATION_DATE      := fnd_date.displaydt_to_date(p_lot_rec(4), FND_TIMEZONES.GET_CLIENT_TIMEZONE_CODE);
end if;
l_lot_rec.LAST_UPDATE_DATE     := sysdate;
l_lot_rec.LAST_UPDATED_BY      := FND_GLOBAL.USER_ID;
l_lot_rec.CREATION_DATE        := sysdate;
l_lot_rec.CREATED_BY           := FND_GLOBAL.USER_ID;
l_lot_rec.LAST_UPDATE_LOGIN    := FND_GLOBAL.LOGIN_ID;
/*
	inv_lot_api_pub.create_inv_lot
	(
		p_lot_rec               => l_lot_rec
		,p_source                => NULL
		,p_api_version           => 1.0
		,p_init_msg_list         => fnd_api.g_true
		,p_commit                => fnd_api.g_false
		,p_validation_level      => fnd_api.g_valid_level_full
		,p_origin_txn_id         => 1
	);
*/
 inv_lot_api_pub.create_inv_lot(
   x_return_status              => x_return_status
  ,x_msg_count                  => x_message_count
  ,x_msg_data                    => x_message_data
  , p_inventory_item_id      => l_lot_rec.INVENTORY_ITEM_ID
  , p_organization_id        => l_lot_rec.ORGANIZATION_ID
  , p_lot_number             => l_lot_rec.LOT_NUMBER
  , p_expiration_date        => l_lot_rec.EXPIRATION_DATE
  , p_disable_flag           => NULL
  , p_attribute_category     => NULL
  , p_lot_attribute_category => NULL
  , p_attributes_tbl         => l_char_tbl
  , p_c_attributes_tbl       => l_char_tbl
  , p_n_attributes_tbl       => l_number_tbl
  , p_d_attributes_tbl       => l_date_tbl
  , p_grade_code             => NULL
  , p_origination_date       => NULL
  , p_date_code              => NULL
  , p_status_id              => NULL
  , p_change_date            => NULL
  , p_age                    => NULL
  , p_retest_date            => NULL
  , p_maturity_date          => NULL
  , p_item_size              => NULL
  , p_color                  => NULL
  , p_volume                 => NULL
  , p_volume_uom             => NULL
  , p_place_of_origin        => NULL
  , p_best_by_date           => NULL
  , p_length                 => NULL
  , p_length_uom             => NULL
  , p_recycled_content       => NULL
  , p_thickness              => NULL
  , p_thickness_uom          => NULL
  , p_width                  => NULL
  , p_width_uom              => NULL
  , p_territory_code         => NULL
  , p_supplier_lot_number    => NULL
  , p_vendor_name            => NULL
  , p_source                 => NULL
  ) ;
	FND_MSG_PUB.Count_And_Get (p_count => x_message_count, p_data => x_message_data);
EXCEPTION
        WHEN OTHERS THEN
                x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
                FND_MESSAGE.SET_NAME('GMO','GMO_VBATCH_UNEXPECTED_DB_ERR');
                FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
                FND_MESSAGE.SET_TOKEN('ERROR_CODE',SQLCODE);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_vbatch_task_pvt.create_lot', FALSE);
                end if;
                FND_MSG_PUB.ADD;
                FND_MSG_PUB.Count_And_Get (p_count => x_message_count, p_data => x_message_data);
END create_lot;

procedure generate_lot(
p_organization_id         IN NUMBER
,p_inventory_item_id      IN NUMBER
,x_lot_number             OUT NOCOPY VARCHAR2
,x_return_status           OUT NOCOPY VARCHAR2
,x_message_count           OUT NOCOPY NUMBER
,x_message_data            OUT NOCOPY VARCHAR2
)
IS
BEGIN
	x_lot_number := INV_LOT_API_PUB.auto_gen_lot
			(
                         p_org_id                => p_organization_id,
                         p_inventory_item_id     => p_inventory_item_id,
                         p_lot_generation        => NULL,
                         p_lot_uniqueness        => NULL,
                         p_lot_prefix            => NULL,
                         p_zero_pad              => NULL,
                         p_lot_length            => NULL,
                         p_transaction_date      => NULL,
                         p_revision              => NULL,
                         p_subinventory_code          => NULL,
                         p_locator_id                 => NULL,
                         p_transaction_type_id        => NULL,
                         p_transaction_action_id      => NULL,
                         p_transaction_source_type_id => NULL,
                         p_lot_number                 => NULL,
                         p_api_version                => 1.0,
                         p_init_msg_list              => FND_API.G_FALSE,
                         p_commit                     => FND_API.G_FALSE,
                         p_validation_level           => NULL,
                         p_parent_lot_number          => null,
                         x_return_status              => x_return_status,
                         x_msg_count                  => x_message_count,
                         x_msg_data                    => x_message_data
			);

        FND_MSG_PUB.Count_And_Get (p_count => x_message_count, p_data => x_message_data);
EXCEPTION
        WHEN OTHERS THEN
                x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
                FND_MESSAGE.SET_NAME('GMO','GMO_VBATCH_UNEXPECTED_DB_ERR');
                FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
                FND_MESSAGE.SET_TOKEN('ERROR_CODE',SQLCODE);
                if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_vbatch_task_pvt.generate_lot', FALSE);
                end if;
                FND_MSG_PUB.ADD;
                FND_MSG_PUB.Count_And_Get (p_count => x_message_count, p_data => x_message_data);
END generate_lot;

procedure get_lot_event_key (
p_organization_id         IN NUMBER
,p_inventory_item_id      IN NUMBER
,p_lot_number             IN VARCHAR2
,x_lot_event_key          OUT NOCOPY VARCHAR2
)
IS
BEGIN

select gen_object_id into x_lot_event_key from mtl_lot_numbers
where organization_id = p_organization_id
and inventory_item_id = p_inventory_item_id
and lot_number = p_lot_number;

END get_lot_event_key;

end GMO_VBATCH_TASK_PVT;

/
