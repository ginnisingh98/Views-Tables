--------------------------------------------------------
--  DDL for Package Body CSI_JAVA_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_JAVA_INTERFACE_PKG" AS
/* $Header: csivjib.pls 120.13.12010000.3 2009/07/24 21:41:51 lakmohan ship $ */

/*----------------------------------------------------*/
/* ****************Important***************************/
/* This package is created for JAVA Interface to      */
/* Installed Base(CSI). The procedures here are       */
/* subject to change without notice.                  */
/* History:
   5/6/2005 115.45 bug 4348762, should store status name in status_text,
                           not sts_code, Xiangyang Li
*/
/*----------------------------------------------------*/

-- --------------------------------------------------------
-- Define global variables
-- --------------------------------------------------------

G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSI_JAVA_INTERFACE_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csivjib.pls';

/*----------------------------------------------------*/
/* procedure name: create_item_instance               */
/* description :   procedure used to                  */
/*                 create item instances              */
/*----------------------------------------------------*/

TYPE connected_relationship_rec  IS RECORD
(
	   object_id number,
	   subject_id number,
	   swapflag varchar2(1)
);
TYPE instanceid_rec  IS RECORD
(
    instance_id number
);
TYPE connected_relationship_tbl IS TABLE OF connected_relationship_rec INDEX BY BINARY_INTEGER;
TYPE instanceid_tbl1 IS TABLE OF instanceid_rec INDEX BY BINARY_INTEGER;
TYPE instanceid_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

PROCEDURE create_item_instance
 (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2
    ,p_init_msg_list         IN     VARCHAR2
    ,p_validation_level      IN     NUMBER
    ,p_instance_rec          IN OUT NOCOPY csi_datastructures_pub.instance_rec
    ,p_party_tbl             IN OUT NOCOPY csi_datastructures_pub.party_tbl
    ,p_account_tbl           IN OUT NOCOPY csi_datastructures_pub.party_account_tbl
    ,p_txn_rec               IN OUT NOCOPY csi_datastructures_pub.transaction_rec
    ,x_return_status         OUT    NOCOPY VARCHAR2
    ,x_msg_count             OUT    NOCOPY NUMBER
    ,x_msg_data              OUT    NOCOPY VARCHAR2
 )
IS
    l_api_name                         CONSTANT VARCHAR2(30) := 'create_item_instance';
    l_api_version                     CONSTANT NUMBER      := 1.0;
    p_ext_attrib_values_tbl CSI_DATASTRUCTURES_PUB.EXTEND_ATTRIB_VALUES_TBL;
    p_pricing_attrib_tbl CSI_DATASTRUCTURES_PUB.PRICING_ATTRIBS_TBL;
    p_org_assignments_tbl CSI_DATASTRUCTURES_PUB.ORGANIZATION_UNITS_TBL;
    p_asset_assignment_tbl CSI_DATASTRUCTURES_PUB.INSTANCE_ASSET_TBL;
BEGIN

	SAVEPOINT  create_item_instance;

-- Now call the stored program
  csi_item_instance_pub.create_item_instance(
    p_api_version,
    p_commit,
    p_init_msg_list,
    p_validation_level,
    p_instance_rec,
    p_ext_attrib_values_tbl,
    p_party_tbl,
    p_account_tbl,
    p_pricing_attrib_tbl,
    p_org_assignments_tbl,
    p_asset_assignment_tbl,
    p_txn_rec,
    x_return_status,
    x_msg_count,
    x_msg_data);

    FND_MSG_PUB.Count_And_Get
      (p_encoded => FND_API.G_FALSE,
       p_count   => x_msg_count,
       p_data    => x_msg_data);

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		ROLLBACK TO create_item_instance;
		FND_MSG_PUB.Count_And_Get
    		(  	p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
        		p_data  => x_msg_data
    		);

  	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		ROLLBACK TO create_item_instance;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count => x_msg_count,
        		p_data  => x_msg_data
    		);

   	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		ROLLBACK TO create_item_instance;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
   	    	FND_MSG_PUB.Add_Exc_Msg
   	    	(G_PKG_NAME,
    	     l_api_name
	    	);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);

END create_item_instance;

/*----------------------------------------------------*/
/* procedure name: getContracts                       */
/* description :   procedure used to                  */
/*                 get the contract details           */
/*----------------------------------------------------*/
PROCEDURE getContracts
(
  product_id		IN  Number
  ,x_return_status 	OUT NOCOPY Varchar2
  ,x_msg_count		OUT NOCOPY Number
  ,x_msg_data		OUT NOCOPY Varchar2
  ,x_output_contracts	OUT NOCOPY csi_output_tbl_ib
)
IS
   l_api_name         CONSTANT VARCHAR2(30) := 'getContracts';
   l_api_version      CONSTANT NUMBER      := 1.0;
   l_inp_rec          oks_entitlements_pub.input_rec_ib;
   l_output_contracts   oks_entitlements_pub.output_tbl_ib;
   l_index            number;
   l_flag             VARCHAR2(2);
   l_debug_level      NUMBER;

Begin
     -- Check the profile option debug_level for debug message reporting
    l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

	fnd_profile.get('CSI_IB_SHOW_ALL_CONTRACTS', l_flag );
	l_flag := nvl(l_flag, 'N');
    l_inp_rec.validate_flag := l_flag;
    l_inp_rec.product_id := product_id;
    l_inp_rec.calc_resptime_flag := 'N';

    -- If debug_level = 1 then dump the procedure name
    IF (l_debug_level > 0) THEN
       csi_gen_utility_pvt.put_line( 'getContracts');
    END IF;

    -- If the debug level = 2 then dump all the parameters values.
    IF (l_debug_level > 1) THEN
	   csi_gen_utility_pvt.put_line( 'getContracts');
	   csi_gen_utility_pvt.put_line('Dumping the values passed to OKS_ENTITLEMENTS_PUB.GET_CONTRACTS:');
	   csi_gen_utility_pvt.put_line('Instance_id                 :'||l_inp_rec.product_id);
	   csi_gen_utility_pvt.put_line('validate_flag               :'||l_inp_rec.validate_flag);
	   csi_gen_utility_pvt.put_line('calc_resptime_flag          :'||l_inp_rec.calc_resptime_flag);
    END IF;

    OKS_ENTITLEMENTS_PUB.GET_CONTRACTS( p_api_version => 1.0,
                                       p_init_msg_list => 'T',
                                       p_inp_rec => l_inp_rec,
                                       x_return_status => x_return_status,
                                       x_msg_count => x_msg_count,
                                       x_msg_data => x_msg_data,
                                       x_ent_contracts => l_output_contracts);
      IF 0 < l_output_contracts.count() THEN
        l_index := l_output_contracts.FIRST;
        LOOP
            x_output_contracts(l_index).contract_id := l_output_contracts(l_index).contract_id;
            x_output_contracts(l_index).contract_number := l_output_contracts(l_index).contract_number;
            x_output_contracts(l_index).contract_number_modifier := l_output_contracts(l_index).contract_number_modifier;
--            x_output_contracts(l_index).sts_code := l_output_contracts(l_index).sts_code;
-- bug# 2620148, need to return translated status, not status id
-- xili 10/24/2002
-- bug 4348762, should store status meaning in status_text, not sts_code which has 30 char limit
-- xili 5/6/2005
            x_output_contracts(l_index).sts_code := l_output_contracts(l_index).sts_code;
            select meaning into x_output_contracts(l_index).status_text from OKC_STATUSES_V where code = l_output_contracts(l_index).sts_code;
            x_output_contracts(l_index).service_line_id := l_output_contracts(l_index).service_line_id;
            x_output_contracts(l_index).service_name := l_output_contracts(l_index).service_name;
            x_output_contracts(l_index).service_description := l_output_contracts(l_index).service_description;
            x_output_contracts(l_index).coverage_term_line_id := l_output_contracts(l_index).coverage_term_line_id;
            x_output_contracts(l_index).Coverage_term_name := l_output_contracts(l_index).Coverage_term_name;
            x_output_contracts(l_index).coverage_term_description := l_output_contracts(l_index).coverage_term_description;
            x_output_contracts(l_index).service_start_date := l_output_contracts(l_index).service_start_date;
            x_output_contracts(l_index).service_END_date := l_output_contracts(l_index).service_END_date;
            x_output_contracts(l_index).warranty_flag := l_output_contracts(l_index).warranty_flag;
            x_output_contracts(l_index).eligible_for_entitlement := l_output_contracts(l_index).eligible_for_entitlement;
            x_output_contracts(l_index).date_terminated := l_output_contracts(l_index).date_terminated;

            EXIT WHEN l_index = l_output_contracts.LAST;
            l_index := l_output_contracts.NEXT(l_index);
        END LOOP;
       END IF;
	FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
	     p_data  => x_msg_data
		);

EXCEPTION

    WHEN NO_DATA_FOUND THEN
      NULL;

    WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
--		ROLLBACK TO create_item_instance;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count => x_msg_count,
        		p_data  => x_msg_data
    		);

  	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
--		ROLLBACK TO create_item_instance;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count => x_msg_count,
        		p_data  => x_msg_data
    		);
WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
--		ROLLBACK TO create_item_instance;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
   	    	FND_MSG_PUB.Add_Exc_Msg
   	    	(G_PKG_NAME,
    	     l_api_name
	    	);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);
END getContracts;

/*------------------------------------------------------*/
/* procedure name: copy_item_instance                   */
/* description :  Copies an instace from an instance    */
/*                                                      */
/*                                                      */
/*------------------------------------------------------*/

PROCEDURE copy_item_instance
 (
   p_api_version            IN         NUMBER
  ,p_commit                 IN         VARCHAR2
  ,p_init_msg_list          IN         VARCHAR2
  ,p_validation_level       IN         NUMBER
  ,p_source_instance_rec    IN         csi_datastructures_pub.instance_rec
  ,p_copy_ext_attribs       IN         VARCHAR2
  ,p_copy_org_assignments   IN         VARCHAR2
  ,p_copy_parties           IN         VARCHAR2
  ,p_copy_contacts          IN         VARCHAR2
  ,p_copy_accounts          IN         VARCHAR2
  ,p_copy_asset_assignments IN         VARCHAR2
  ,p_copy_pricing_attribs   IN         VARCHAR2
  ,p_copy_inst_children     IN         VARCHAR2
  ,p_txn_rec                IN  OUT    NOCOPY csi_datastructures_pub.transaction_rec
  ,x_new_instance_tbl           OUT    NOCOPY csi_datastructures_pub.instance_tbl
  ,x_return_status              OUT    NOCOPY VARCHAR2
  ,x_msg_count                  OUT    NOCOPY NUMBER
  ,x_msg_data                   OUT    NOCOPY VARCHAR2
 )
 IS
    l_api_name                         CONSTANT VARCHAR2(30) := 'copy_item_instance';
    l_api_version                     CONSTANT NUMBER      := 1.0;
BEGIN
	SAVEPOINT  copy_item_instance;

  csi_item_instance_pub.copy_item_instance(
    p_api_version => p_api_version,
    p_commit => p_commit,
    p_init_msg_list => p_init_msg_list,
    p_validation_level => p_validation_level,
    p_source_instance_rec => p_source_instance_rec,
    p_copy_ext_attribs => p_copy_ext_attribs,
    p_copy_org_assignments => p_copy_org_assignments,
    p_copy_parties => p_copy_parties,
    p_copy_party_contacts => p_copy_contacts,
    p_copy_accounts => p_copy_accounts,
    p_copy_asset_assignments => p_copy_asset_assignments,
    p_copy_pricing_attribs => p_copy_pricing_attribs,
    p_copy_inst_children => p_copy_inst_children,
    p_txn_rec => p_txn_rec,
    x_new_instance_tbl => x_new_instance_tbl,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data => x_msg_data);

	FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
	     p_data  => x_msg_data
		);

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		ROLLBACK TO copy_item_instance;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count => x_msg_count,
        		p_data  => x_msg_data
    		);

  	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		ROLLBACK TO copy_item_instance;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count => x_msg_count,
        		p_data  => x_msg_data
    		);

   	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		ROLLBACK TO copy_item_instance;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
   	    	FND_MSG_PUB.Add_Exc_Msg
   	    	(G_PKG_NAME,
    	     l_api_name
	    	);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);
END copy_item_instance;


/*--------------------------------------------------------*/
/* Procedure name:  Split_Item_Instance                   */
/* Description   :  This procedure is used to create split*/
/*                  lines for instance                    */
/*--------------------------------------------------------*/


 PROCEDURE Split_Item_Instance
 (
   p_api_version                 IN      NUMBER
  ,p_commit                      IN      VARCHAR2
  ,p_init_msg_list               IN      VARCHAR2
  ,p_validation_level            IN      NUMBER
  ,p_source_instance_rec         IN OUT  NOCOPY csi_datastructures_pub.instance_rec
  ,p_quantity1                   IN      NUMBER
  ,p_quantity2                   IN      NUMBER
  ,p_copy_ext_attribs            IN      VARCHAR2
  ,p_copy_org_assignments        IN      VARCHAR2
  ,p_copy_parties                IN      VARCHAR2
  ,p_copy_accounts               IN      VARCHAR2
  ,p_copy_asset_assignments      IN      VARCHAR2
  ,p_copy_pricing_attribs        IN      VARCHAR2
  ,p_txn_rec                     IN OUT  NOCOPY csi_datastructures_pub.transaction_rec
  ,x_new_instance_rec            OUT     NOCOPY csi_datastructures_pub.instance_rec
  ,x_return_status               OUT     NOCOPY VARCHAR2
  ,x_msg_count                   OUT     NOCOPY NUMBER
  ,x_msg_data                    OUT     NOCOPY VARCHAR2
 )
IS
    l_api_name              CONSTANT VARCHAR2(30)   := 'SPLIT_ITEM_INSTANCE';
    l_api_version           CONSTANT NUMBER         := 1.0;

BEGIN
	SAVEPOINT  split_item_instance;

  csi_item_instance_pvt.split_item_instance(
    p_api_version,
    p_commit,
    p_init_msg_list,
    p_validation_level,
    p_source_instance_rec,
    p_quantity1,
    p_quantity2,
    p_copy_ext_attribs,
    p_copy_org_assignments,
    p_copy_parties,
    p_copy_accounts,
    p_copy_asset_assignments,
    p_copy_pricing_attribs,
    p_txn_rec,
    x_new_instance_rec,
    x_return_status,
    x_msg_count,
    x_msg_data);

	FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
	     p_data  => x_msg_data
		);

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		ROLLBACK TO split_item_instance;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count => x_msg_count,
        		p_data  => x_msg_data
    		);

  	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		ROLLBACK TO split_item_instance;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count => x_msg_count,
        		p_data  => x_msg_data
    		);

   	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		ROLLBACK TO split_item_instance;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
   	    	FND_MSG_PUB.Add_Exc_Msg
   	    	(G_PKG_NAME,
    	     l_api_name
	    	);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);

END Split_Item_Instance;

/*---------------------------------------------------*/
/* Procedure name:  Split_Item_Instance_lines        */
/* Description   :  This procedure is used to create */
/*                  split lines for instance         */
/*---------------------------------------------------*/
 PROCEDURE Split_Item_Instance_Lines
 (
   p_api_version                 IN      NUMBER
  ,p_commit                      IN      VARCHAR2
  ,p_init_msg_list               IN      VARCHAR2
  ,p_validation_level            IN      NUMBER
  ,p_source_instance_rec         IN OUT  NOCOPY csi_datastructures_pub.instance_rec
  ,p_copy_ext_attribs            IN      VARCHAR2
  ,p_copy_org_assignments        IN      VARCHAR2
  ,p_copy_parties                IN      VARCHAR2
  ,p_copy_accounts               IN      VARCHAR2
  ,p_copy_asset_assignments      IN      VARCHAR2
  ,p_copy_pricing_attribs        IN      VARCHAR2
  ,p_txn_rec                     IN OUT  NOCOPY csi_datastructures_pub.transaction_rec
  ,x_new_instance_tbl            OUT     NOCOPY csi_datastructures_pub.instance_tbl
  ,x_return_status               OUT     NOCOPY VARCHAR2
  ,x_msg_count                   OUT     NOCOPY NUMBER
  ,x_msg_data                    OUT     NOCOPY VARCHAR2
 )
IS
    l_api_name              CONSTANT VARCHAR2(30)   := 'SPLIT_ITEM_INSTANCE_LINES';
    l_api_version           CONSTANT NUMBER         := 1.0;
BEGIN

	SAVEPOINT  split_item_instance_lines;

    csi_item_instance_pvt.split_item_instance_lines(
      p_api_version,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      p_source_instance_rec,
      p_copy_ext_attribs,
      p_copy_org_assignments,
      p_copy_parties,
      p_copy_accounts,
      p_copy_asset_assignments,
      p_copy_pricing_attribs,
      p_txn_rec,
      x_new_instance_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

	FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
	     p_data  => x_msg_data
		);

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		ROLLBACK TO split_item_instance_lines;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count => x_msg_count,
        		p_data  => x_msg_data
    		);

  	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		ROLLBACK TO split_item_instance_lines;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count => x_msg_count,
        		p_data  => x_msg_data
    		);

   	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		ROLLBACK TO split_item_instance_lines;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
   	    	FND_MSG_PUB.Add_Exc_Msg
   	    	(G_PKG_NAME,
    	     l_api_name
	    	);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);

END Split_Item_Instance_Lines;

/*----------------------------------------------------*/
/* procedure name: Get_Coverage_For_Prod_Sch          */
/* description :   procedure used to get contract     */
/*                 coverage info for product search on*/
/*                 a given contract number            */
/*----------------------------------------------------*/
PROCEDURE Get_Coverage_For_Prod_Sch
 (
  contract_number       IN  VARCHAR2
  ,x_coverage_tbl       OUT NOCOPY csi_coverage_tbl_ib
  ,x_sequence_id        OUT NOCOPY NUMBER
  ,x_return_status 	OUT NOCOPY Varchar2
  ,x_msg_count		OUT NOCOPY Number
  ,x_msg_data   	OUT NOCOPY Varchar2
 )
 IS
    l_api_name              CONSTANT VARCHAR2(30)   := 'Get_Coverage_For_Prod_Sch';
    l_api_version           CONSTANT NUMBER         := 1.0;
    l_count              NUMBER := 0;
    l_flag               VARCHAR2(2);
    l_rec_count 		NUMBER := 1;
    l_return_status	VARCHAR2(1);
    l_ent_contracts      OKS_ENTITLEMENTS_PUB.ent_cont_tbl;
    l_inp_rec            OKS_ENTITLEMENTS_PUB.inp_cont_rec;
    l_debug_level      NUMBER;

    l_Seq              Number;
    l_Creation_Date    DATE ;
    l_search_oks_temp    csi_search_oks_temp%ROWTYPE;
    l_found            BOOLEAN;

    Cursor c_search_oks_temp IS
    Select *
    From   csi_search_oks_temp
    Where  creation_date < sysdate
    and    rownum <= 1
    For Update NoWait;

 BEGIN
	fnd_profile.get('CSI_IB_SHOW_ALL_CONTRACTS', l_flag );

	-- Check the profile option debug_level for debug message reporting
    l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

	l_flag := nvl(l_flag, 'N');

    l_inp_rec.contract_number := contract_number;
    l_inp_rec.party_id        := NULL;
    l_inp_rec.site_id         := NULL;
    l_inp_rec.cust_acct_id    := NULL;
    l_inp_rec.system_id       := NULL;
    l_inp_rec.item_id         := NULL;
    l_inp_rec.product_id      := NULL;
    l_inp_rec.request_date    := sysdate;
    l_inp_rec.validate_flag   := l_flag;

    -- If debug_level = 1 then dump the procedure name
    IF (l_debug_level > 0) THEN
 		csi_gen_utility_pvt.put_line( 'Get_Coverage_For_Prod_Sch');
    END IF;

    /*-- Purging Temp Table before Further Operation bug 4736062-- */
    OPEN c_search_oks_temp;
    FETCH c_search_oks_temp INTO l_search_oks_temp;
    IF c_search_oks_temp%FOUND THEN
       DELETE csi_search_oks_temp
       WHERE creation_date < sysdate -1;
    END IF;
    CLOSE c_search_oks_temp;
    --- End changes for bug 4736062

    OKS_ENTITLEMENTS_PUB.GET_CONTRACTS( p_api_version => 1.0,
                                       p_init_msg_list => 'T',
                                       p_inp_rec => l_inp_rec,
                                       x_return_status => l_return_status,
                                       x_msg_count => x_msg_count,
                                       x_msg_data => x_msg_data,
                                       x_ent_contracts => l_ent_contracts);
    x_return_status := l_return_status;
    IF ( l_return_status ) <> 'S' Then
        Raise FND_API.G_EXC_UNEXPECTED_ERROR;
    End IF;
    /*-- bug 4736062
    -- throw exception when there are too many coverage lines
    IF ( l_ent_contracts.LAST ) > 5000 Then
        FND_MESSAGE.SET_NAME('CSI','CSI_CANT_SEARCH_BY_CONTR_NUM');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
	End IF;
     */
     -- If the debug level = 2 then dump all the output data.
     IF (l_debug_level > 1) THEN
        csi_gen_utility_pvt.put_line('OKS_ENTITLEMENTS_PUB.GET_CONTRACTS() call succeeds:');
        csi_gen_utility_pvt.put_line('Dumping the values gotten from OKS_ENTITLEMENTS_PUB.GET_CONTRACTS():');
        csi_gen_utility_pvt.put_line('l_ent_contracts.count       :'||l_ent_contracts.count);
     END IF;

    l_rec_count := l_ent_contracts.FIRST;

     IF l_rec_count > 0 THEN
       SELECT csi_search_oks_temp_S.NEXTVAL, sysdate
       INTO   l_Seq, l_Creation_Date
       FROM   dual;
       x_sequence_id := l_Seq;
    END IF;

    WHILE l_rec_count is not null
    LOOP
--         x_coverage_tbl(l_rec_count).covered_level_code := l_ent_contracts(l_rec_count).coverage_level_code;
--         x_coverage_tbl(l_rec_count).covered_level_id := l_ent_contracts(l_rec_count).coverage_level_id;

         l_found := FALSE;
         IF x_coverage_tbl.count > 0 THEN
            FOR j in x_coverage_tbl.first..x_coverage_tbl.last LOOP
              IF x_coverage_tbl(j).covered_level_code = l_ent_contracts(l_rec_count).coverage_level_code THEN
              l_found := TRUE;
              END IF;
            END LOOP;
            IF NOT l_found THEN
              x_coverage_tbl(x_coverage_tbl.count + 1).covered_level_code := l_ent_contracts(l_rec_count).coverage_level_code;
            END IF;

         ELSE
           x_coverage_tbl(1).covered_level_code := l_ent_contracts(l_rec_count).coverage_level_code;
         END IF;

          Insert into csi_search_oks_temp
           (
             id,
             creation_date,
             covered_level_id,
             covered_level_code
           )
           Values
           (
             l_Seq
            ,l_Creation_Date
            ,l_ent_contracts(l_rec_count).coverage_level_id
            ,l_ent_contracts(l_rec_count).coverage_level_code
           );

	 EXIT WHEN l_rec_count = l_ent_contracts.LAST;
         l_rec_count := l_ent_contracts.NEXT(l_rec_count);
    END LOOP;
    COMMIT;
	FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
	     p_data  => x_msg_data
		);

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count => x_msg_count,
        		p_data  => x_msg_data
    		);

  	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count => x_msg_count,
        		p_data  => x_msg_data
    		);

   	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
   	    	FND_MSG_PUB.Add_Exc_Msg
   	    	(G_PKG_NAME,
    	     l_api_name
	    	);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);

END Get_Coverage_For_Prod_Sch;

/*----------------------------------------------------*/
/* procedure name: Get_Contract_Where_Clause          */
/* description :   procedure used to get Product      */
/*                 Search where clause for a given    */
/*                 contract number                    */
/*----------------------------------------------------*/
 PROCEDURE Get_Contract_Where_Clause
 (
  contract_number       IN  VARCHAR2
  ,instance_table_name  IN  VARCHAR2
  ,x_where_clause       OUT    NOCOPY VARCHAR2
  ,x_return_status 	OUT NOCOPY Varchar2
  ,x_msg_count		OUT NOCOPY Number
  ,x_msg_data			OUT NOCOPY Varchar2
 )
 IS
    l_api_name              CONSTANT VARCHAR2(30)   := 'Get_Contract_Where_Clause';
    l_api_version           CONSTANT NUMBER         := 1.0;
    l_count              NUMBER := 0;
    l_contract_where_clause VARCHAR2(4000) DEFAULT NULL;
    l_covered_party_id   VARCHAR2(4000) DEFAULT NULL;
    l_covered_site_id    VARCHAR2(4000) DEFAULT NULL;
    l_covered_acct_id    VARCHAR2(4000) DEFAULT NULL;
    l_covered_system_id  VARCHAR2(4000) DEFAULT NULL;
    l_covered_item_id    VARCHAR2(4000) DEFAULT NULL;
    l_covered_cp_id      VARCHAR2(4000) DEFAULT NULL;
    l_covered_level_code OKC_LINE_STYLES_B.LTY_CODE%TYPE;
    l_coverage_level_id  NUMBER;
    l_flag               VARCHAR2(2);
    l_rec_count 		NUMBER := 1;
    l_row_count		NUMBER;
    l_return_status	VARCHAR2(1);
    l_ent_contracts      OKS_ENTITLEMENTS_PUB.ent_cont_tbl;
    l_inp_rec            OKS_ENTITLEMENTS_PUB.inp_cont_rec;
    l_debug_level      NUMBER;
	l_instance_table_name  VARCHAR2(200);
 BEGIN
	fnd_profile.get('CSI_IB_SHOW_ALL_CONTRACTS', l_flag );

	-- Check the profile option debug_level for debug message reporting
     l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

	l_flag := nvl(l_flag, 'N');

        l_inp_rec.contract_number := contract_number;
        --l_inp_rec.service_line_id := NULL;
        l_inp_rec.party_id        := NULL;
        l_inp_rec.site_id         := NULL;
        l_inp_rec.cust_acct_id    := NULL;
        l_inp_rec.system_id       := NULL;
        l_inp_rec.item_id         := NULL;
        l_inp_rec.product_id      := NULL;
        l_inp_rec.request_date    := sysdate;
        l_inp_rec.validate_flag   := l_flag;

    -- If debug_level = 1 then dump the procedure name
    IF (l_debug_level > 0) THEN
 		csi_gen_utility_pvt.put_line( 'Get_Contract_Where_Clause');
    END IF;

    -- If the debug level = 2 then dump all the parameters values.
    IF (l_debug_level > 1) THEN
        csi_gen_utility_pvt.put_line( 'Get_Contract_Where_Clause');
        csi_gen_utility_pvt.put_line('Dumping the values passed to OKS_ENTITLEMENTS_PUB.GET_CONTRACTS():');
        csi_gen_utility_pvt.put_line('contract_number             :'||l_inp_rec.contract_number);
        csi_gen_utility_pvt.put_line('request_date                :'||l_inp_rec.request_date);
        csi_gen_utility_pvt.put_line('validate_flag               :'||l_inp_rec.validate_flag);
    END IF;


      OKS_ENTITLEMENTS_PUB.GET_CONTRACTS( p_api_version => 1.0,
                                       p_init_msg_list => 'T',
                                       p_inp_rec => l_inp_rec,
                                       x_return_status => l_return_status,
                                       x_msg_count => x_msg_count,
                                       x_msg_data => x_msg_data,
                                       x_ent_contracts => l_ent_contracts);
      x_return_status := l_return_status;
      IF ( l_return_status ) <> 'S' Then
/*
        IF ( FND_MSG_PUB.Count_Msg > 0 ) Then
          FOR i in 1..FND_MSG_PUB.Count_Msg LOOP
            FND_MSG_PUB.Get(p_msg_index => i,
                            p_encoded => 'F',
                            p_data => l_msg_data,
                            p_msg_index_out => l_msg_index_out );
            fnd_message.set_string(l_msg_data);
            fnd_message.error;
          End LOOP;
        End IF;
*/
        Raise FND_API.G_EXC_UNEXPECTED_ERROR;
      End IF;

-- fnd_message.debug('l_rec_count = '||to_char(l_rec_count));

     -- If the debug level = 2 then dump all the output data.
     IF (l_debug_level > 1) THEN
         csi_gen_utility_pvt.put_line('OKS_ENTITLEMENTS_PUB.GET_CONTRACTS() call succeeds:');
	    csi_gen_utility_pvt.put_line('Dumping the values gotten from OKS_ENTITLEMENTS_PUB.GET_CONTRACTS():');
	    csi_gen_utility_pvt.put_line('l_ent_contracts.count       :'||l_ent_contracts.count);
     END IF;

      l_row_count := 1;
      l_rec_count := l_ent_contracts.FIRST;

      -- Bug 1783709 srramakr. When queried by contract #, system gives value error.
      -- This is becoz the CPs returned by OKS may not fit in the valriable used to build the WHERE clause.
      -- So, we just give a meaningful message.
      WHILE l_rec_count is not null
      LOOP
      Begin

       l_covered_level_code := l_ent_contracts(l_rec_count).coverage_level_code ;
       l_coverage_level_id  := l_ent_contracts(l_rec_count).coverage_level_id ;

       -- If the debug level = 2 then dump each output record.
	  IF (l_debug_level > 1) THEN
		 csi_gen_utility_pvt.put_line('---- Contract Record ' || l_rec_count || '----');
		 csi_gen_utility_pvt.put_line('l_covered_level_code        :'||l_covered_level_code);
		 csi_gen_utility_pvt.put_line('l_coverage_level_id         :'||to_char(l_coverage_level_id));
       END IF;
-- fnd_message.debug('l_covered_level_code = '||l_ent_contracts(l_rec_count).coverage_level_code);
-- fnd_message.debug('l_covered_level_id = '||l_ent_contracts(l_rec_count).coverage_level_id);

            IF (l_covered_level_code = 'COVER_PTY') Then

                IF l_covered_party_id is NULL THEN

                  l_covered_party_id :=  to_char(l_coverage_level_id)  ;
                ELSE
                  l_covered_party_id :=  l_covered_party_id ||','||to_char(l_coverage_level_id)  ;

                END IF;
            Elsif (l_covered_level_code = 'COVER_SITE') Then

               IF l_covered_site_id IS NULL THEN

                l_covered_site_id  := to_char(l_coverage_level_id) ;

               ELSE
                l_covered_site_id  :=  l_covered_site_id ||','||to_char(l_coverage_level_id) ;

               END IF;
            Elsif (l_covered_level_code = 'COVER_CUST') Then

               IF l_covered_acct_id IS NULL THEN

                 l_covered_acct_id := to_char(l_coverage_level_id)  ;
               ELSE
                 l_covered_acct_id := l_covered_acct_id  ||','||to_char(l_coverage_level_id)  ;

               END IF;
            Elsif (l_covered_level_code = 'COVER_SYS') Then

                IF l_covered_system_id IS NULL THEN
                   l_covered_system_id := to_char(l_coverage_level_id)  ;
                ELSE
                   l_covered_system_id := l_covered_system_id  ||','||to_char(l_coverage_level_id)  ;
                END IF;

            Elsif (l_covered_level_code = 'COVER_ITEM') Then

                IF l_covered_item_id IS NULL THEN
                  l_covered_item_id := to_char(l_coverage_level_id ) ;
                ELSE
                  l_covered_item_id := l_covered_item_id  ||','||to_char(l_coverage_level_id ) ;
                END IF;

            Elsif (l_covered_level_code = 'COVER_PROD') Then

                 IF  l_covered_cp_id IS NULL THEN
                   l_covered_cp_id := to_char(l_coverage_level_id) ;
                ELSE
                   l_covered_cp_id := l_covered_cp_id ||','||to_char(l_coverage_level_id) ;
                END IF;
            End IF;

/*
fnd_message.debug('l_covered_party_id = '||l_covered_party_id);
fnd_message.debug('l_covered_site_id  = '||l_covered_site_id);
fnd_message.debug('l_covered_acct_id  = '||l_covered_acct_id);
fnd_message.debug('l_covered_system_id= '||l_covered_system_id);
fnd_message.debug('l_covered_item_id  = '||l_covered_item_id);
*/
           l_rec_count := l_ent_contracts.NEXT(l_rec_count);
       End;
       End LOOP;

	  -- If the debug level = 2 then dump each output record.
       IF (l_debug_level > 1) THEN
	      csi_gen_utility_pvt.put_line('l_covered_party_id          :'||l_covered_party_id);
           csi_gen_utility_pvt.put_line('l_covered_site_id           :'||l_covered_site_id);
           csi_gen_utility_pvt.put_line('l_covered_acct_id           :'||l_covered_acct_id);
           csi_gen_utility_pvt.put_line('l_covered_system_id         :'||l_covered_system_id);
           csi_gen_utility_pvt.put_line('l_covered_item_id           :'||l_covered_item_id);
       END IF;

            l_instance_table_name := ' ' || instance_table_name;
            IF (length(instance_table_name) > 0 ) THEN
			   l_instance_table_name := l_instance_table_name || '.';
			END IF;

            IF (l_covered_party_id IS NOT NULL) Then

              IF l_contract_where_clause IS NULL THEN

                l_contract_where_clause := l_instance_table_name || 'instance_id in ( select instance_id from csi_i_parties where party_id in ( '
                                           ||l_covered_party_id||' ) )' ;

              ELSE
                l_contract_where_clause := l_contract_where_clause ||' '||' AND'||
                                           l_instance_table_name || 'instance_id in ( select instance_id from csi_i_parties where party_id in ( '
                                           ||l_covered_party_id||' ) )' ;
              END IF;
            END IF;

            IF (l_covered_site_id IS NOT NULL ) Then

                IF l_contract_where_clause IS NULL THEN
                   l_contract_where_clause  :=  l_instance_table_name || 'install_location_type_code = ''HZ_PARTY_SITES'' and '
												|| l_instance_table_name || 'install_location_id IN ( '
                                                ||l_covered_site_id ||' )' ;

                ELSE
                   l_contract_where_clause  := l_contract_where_clause ||' '||' AND'||
                                               l_instance_table_name || 'install_location_type_code = ''HZ_PARTY_SITES'' and '
												|| l_instance_table_name || 'install_location_id IN ( '
                                                ||l_covered_site_id ||' )' ;
                END IF;

            END IF;

            IF (l_covered_acct_id  IS NOT NULL) Then

                IF l_contract_where_clause IS NULL THEN
                   l_contract_where_clause := l_instance_table_name || 'instance_id in ( select instance_id from ' ||
                     ' csi_i_parties p, csi_ip_accounts a where a.instance_party_id = p.instance_party_id ' ||
                     ' and a.party_account_id IN ( '||l_covered_acct_id  ||' ) )'  ;
                ELSE
                   l_contract_where_clause := l_contract_where_clause ||' '||' AND'||
                     l_instance_table_name || 'instance_id in ( select instance_id from ' ||
                     ' csi_i_parties p, csi_ip_accounts a where a.instance_party_id = p.instance_party_id ' ||
                     ' and a.party_account_id IN ( '||l_covered_acct_id  ||' ) )'  ;
                END IF;

            END IF;

            IF (l_covered_system_id IS NOT NULL) Then

                IF l_contract_where_clause IS NULL THEN

                   l_contract_where_clause := l_instance_table_name || 'system_id IN ( '||l_covered_system_id  ||' )' ;
                ELSE
                   l_contract_where_clause := l_contract_where_clause ||' '||' AND'||
                                              l_instance_table_name || 'system_id IN ( '||l_covered_system_id  ||' )' ;
                END IF;
            END IF;

            IF (l_covered_item_id IS NOT NULL) Then
                IF l_contract_where_clause IS NULL THEN
                   l_contract_where_clause := l_instance_table_name || 'inventory_item_id IN ( '||l_covered_item_id  ||' )' ;
                ELSE
                   l_contract_where_clause := l_contract_where_clause ||' '||' AND'||
                                              l_instance_table_name || 'inventory_item_id IN ( '||l_covered_item_id  ||' )' ;
                END IF;
            END IF;

            IF (l_covered_cp_id IS NOT NULL) Then
                IF l_contract_where_clause IS NULL THEN
                   l_contract_where_clause := l_instance_table_name || 'instance_id IN ( ' ||l_covered_cp_id ||' )' ;
                ELSE
                   l_contract_where_clause := l_contract_where_clause ||' '||' AND'||
                                              l_instance_table_name || 'instance_id IN ( ' ||l_covered_cp_id ||' )' ;
                END IF;
            End IF;

           IF l_contract_where_clause is  NULL THEN

             l_contract_where_clause := l_instance_table_name || 'instance_id = -999 ';


           ELSE
               l_contract_where_clause  := ' ( '||l_contract_where_clause||' )'  ;

           END IF;

           -- fnd_message.debug(' l_contract_where_clause ='|| l_contract_where_clause );

-- contract where clause has been successfully contructed
    x_where_clause := l_contract_where_clause;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count => x_msg_count,
        		p_data  => x_msg_data
    		);

  	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count => x_msg_count,
        		p_data  => x_msg_data
    		);

   	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
   	    	FND_MSG_PUB.Add_Exc_Msg
   	    	(G_PKG_NAME,
    	     l_api_name
	    	);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);

 END Get_Contract_Where_Clause;

/*---------------------------------------------------*/
/* procedure name: get_history_transactions          */
/* description   : Retreive history transactions     */
/*                                                   */
/*---------------------------------------------------*/

PROCEDURE get_history_transactions
( p_api_version                IN  NUMBER
 ,p_commit                     IN  VARCHAR2
 ,p_init_msg_list              IN  VARCHAR2
 ,p_validation_level           IN  NUMBER
 ,p_transaction_id             IN  NUMBER
 ,p_instance_id                IN  NUMBER
 ,x_instance_history_tbl       OUT NOCOPY csi_datastructures_pub.instance_history_tbl
 ,x_party_history_tbl          OUT NOCOPY csi_datastructures_pub.party_history_tbl
 ,x_account_history_tbl        OUT NOCOPY csi_datastructures_pub.account_history_tbl
 ,x_org_unit_history_tbl       OUT NOCOPY csi_datastructures_pub.org_units_history_tbl
 ,x_ins_asset_hist_tbl         OUT NOCOPY csi_datastructures_pub.ins_asset_history_tbl
 ,x_ext_attrib_val_hist_tbl    OUT NOCOPY csi_datastructures_pub.ext_attrib_val_history_tbl
 ,x_version_label_hist_tbl     OUT NOCOPY csi_datastructures_pub.version_label_history_tbl
 ,x_rel_history_tbl            OUT NOCOPY csi_datastructures_pub.relationship_history_tbl
 ,x_return_status              OUT NOCOPY VARCHAR2
 ,x_msg_count                  OUT NOCOPY NUMBER
 ,x_msg_data                   OUT NOCOPY VARCHAR2
 ) IS
l_dummy    VARCHAR2(1);
l_api_name      CONSTANT   VARCHAR2(30)         := 'get_history_transactions';
l_api_version   CONSTANT   NUMBER               := 1.0;
temp_instance_history_tbl  csi_datastructures_pub.instance_history_tbl;
temp_ins_asset_hist_tbl csi_datastructures_pub.ins_asset_history_tbl;
temp_party_history_tbl csi_datastructures_pub.party_history_tbl;
temp_account_history_tbl csi_datastructures_pub.account_history_tbl;
temp_org_unit_history_tbl csi_datastructures_pub.org_units_history_tbl;
temp_ext_attrib_val_hist_tbl csi_datastructures_pub.ext_attrib_val_history_tbl;
temp_rel_history_tbl csi_datastructures_pub.relationship_history_tbl;
x_index number;

BEGIN

        IF fnd_api.to_boolean(p_commit)
        THEN
           SAVEPOINT    get_history_transactions;
        END IF;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (l_api_version       ,
                                                    p_api_version       ,
                                                l_api_name              ,
                                                G_PKG_NAME              )
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;
  /** bug 3304439
   -- Check for the profile option and enable trace
   IF (fnd_profile.value('CSI_ENABLE_SQL_TRACE') = 'Y') THEN
                   dbms_session.set_sql_trace(TRUE);
   END IF;
  **/

   -- End enable trace

   -- Start API body
   --

    x_index := 1;
    BEGIN
      SELECT 'x'
      INTO   l_dummy
      FROM   csi_item_instances_h
      WHERE  transaction_id = p_transaction_id
      AND    ROWNUM = 1;

      csi_item_instance_pvt.get_instance_hist
       ( p_api_version              => 1.0
        ,p_commit                   => fnd_api.g_false
        ,p_init_msg_list            => fnd_api.g_false
        ,p_validation_level         => fnd_api.g_valid_level_full
        ,p_transaction_id           => p_transaction_id
        ,x_instance_history_tbl     => temp_instance_history_tbl
        ,x_return_status            => x_return_status
        ,x_msg_count                => x_msg_count
        ,x_msg_data                 => x_msg_data
       );

       IF temp_instance_history_tbl.count > 0 THEN
        FOR l_ind IN temp_instance_history_tbl.FIRST .. temp_instance_history_tbl.LAST
        LOOP
          if (temp_instance_history_tbl(l_ind).instance_id = p_instance_id) then
            x_instance_history_tbl(x_index) := temp_instance_history_tbl(l_ind);
            x_index := x_index +1;
          end if;
        END LOOP;
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    x_index := 1;
    BEGIN
      SELECT 'x'
      INTO   l_dummy
      FROM   csi_i_assets_h
      WHERE  transaction_id = p_transaction_id
      AND    ROWNUM = 1;
      csi_asset_pvt.get_instance_asset_hist
       ( p_api_version              => 1.0
        ,p_commit                   => fnd_api.g_false
        ,p_init_msg_list            => fnd_api.g_false
        ,p_validation_level         => fnd_api.g_valid_level_full
        ,p_transaction_id           => p_transaction_id
        ,x_ins_asset_hist_tbl       => temp_ins_asset_hist_tbl
        ,x_return_status            => x_return_status
        ,x_msg_count                => x_msg_count
        ,x_msg_data                 => x_msg_data
       );

       IF temp_ins_asset_hist_tbl.count > 0 THEN
        FOR l_ind IN temp_ins_asset_hist_tbl.FIRST .. temp_ins_asset_hist_tbl.LAST
        LOOP
          if (temp_ins_asset_hist_tbl(l_ind).instance_id = p_instance_id) then
            x_ins_asset_hist_tbl(x_index) := temp_ins_asset_hist_tbl(l_ind);
            x_index := x_index +1;
          end if;
        END LOOP;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    x_index := 1;
    BEGIN
      SELECT 'x'
      INTO   l_dummy
      FROM   csi_i_parties_h
      WHERE  transaction_id = p_transaction_id
      AND    ROWNUM = 1;
      csi_party_relationships_pvt.get_inst_party_rel_hist
       ( p_api_version              => 1.0
        ,p_commit                   => fnd_api.g_false
        ,p_init_msg_list            => fnd_api.g_false
        ,p_validation_level         => fnd_api.g_valid_level_full
        ,p_transaction_id           => p_transaction_id
        ,x_party_history_tbl        => temp_party_history_tbl
        ,x_return_status            => x_return_status
        ,x_msg_count                => x_msg_count
        ,x_msg_data                 => x_msg_data
       );

      IF temp_party_history_tbl.count > 0 THEN
        FOR l_ind IN temp_party_history_tbl.FIRST .. temp_party_history_tbl.LAST
        LOOP
          if (temp_party_history_tbl(l_ind).instance_id = p_instance_id) then
            x_party_history_tbl(x_index) := temp_party_history_tbl(l_ind);
            x_index := x_index +1;
          end if;
        END LOOP;
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    x_index := 1;
    BEGIN
      SELECT 'x'
      INTO   l_dummy
      FROM   csi_ip_accounts_h
      WHERE  transaction_id = p_transaction_id
      AND    rownum=1;

      csi_party_relationships_pvt.get_inst_party_account_hist
       ( p_api_version              => 1.0
        ,p_commit                   => fnd_api.g_false
        ,p_init_msg_list            => fnd_api.g_false
        ,p_validation_level         => fnd_api.g_valid_level_full
        ,p_transaction_id           => p_transaction_id
        ,x_account_history_tbl      => temp_account_history_tbl
        ,x_return_status            => x_return_status
        ,x_msg_count                => x_msg_count
        ,x_msg_data                 => x_msg_data
       );

       IF temp_account_history_tbl.count > 0 THEN
        FOR l_ind IN temp_account_history_tbl.FIRST .. temp_account_history_tbl.LAST
        LOOP
          if (temp_account_history_tbl(l_ind).instance_id = p_instance_id) then
            x_account_history_tbl(x_index) := temp_account_history_tbl(l_ind);
            x_index := x_index +1;
          end if;
        END LOOP;
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    x_index := 1;
    BEGIN
      SELECT 'x'
      INTO   l_dummy
      FROM   csi_i_org_assignments_h
      WHERE  transaction_id = p_transaction_id
      AND    ROWNUM = 1;

      csi_organization_unit_pvt.get_org_unit_history
       ( p_api_version              => 1.0
        ,p_commit                   => fnd_api.g_false
        ,p_init_msg_list            => fnd_api.g_false
        ,p_validation_level         => fnd_api.g_valid_level_full
        ,p_transaction_id           => p_transaction_id
        ,x_org_unit_history_tbl     => temp_org_unit_history_tbl
        ,x_return_status            => x_return_status
        ,x_msg_count                => x_msg_count
        ,x_msg_data                 => x_msg_data
       );

       IF temp_org_unit_history_tbl.count > 0 THEN
        FOR l_ind IN temp_org_unit_history_tbl.FIRST .. temp_org_unit_history_tbl.LAST
        LOOP
          if (temp_org_unit_history_tbl(l_ind).instance_id = p_instance_id) then
            x_org_unit_history_tbl(x_index) := temp_org_unit_history_tbl(l_ind);
            x_index := x_index +1;
          end if;
        END LOOP;
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    x_index := 1;
    BEGIN
      SELECT 'x'
      INTO   l_dummy
      FROM   csi_iea_values_h
      WHERE  transaction_id = p_transaction_id
      AND    ROWNUM = 1;

      csi_item_instance_pvt.get_ext_attrib_val_hist
       ( p_api_version              => 1.0
        ,p_commit                   => fnd_api.g_false
        ,p_init_msg_list            => fnd_api.g_false
        ,p_validation_level         => fnd_api.g_valid_level_full
        ,p_transaction_id           => p_transaction_id
        ,x_ext_attrib_val_hist_tbl  => temp_ext_attrib_val_hist_tbl
        ,x_return_status            => x_return_status
        ,x_msg_count                => x_msg_count
        ,x_msg_data                 => x_msg_data
       );

       IF temp_ext_attrib_val_hist_tbl.count > 0 THEN
        FOR l_ind IN temp_ext_attrib_val_hist_tbl.FIRST .. temp_ext_attrib_val_hist_tbl.LAST
        LOOP
          if (temp_ext_attrib_val_hist_tbl(l_ind).instance_id = p_instance_id) then
            x_ext_attrib_val_hist_tbl(x_index) := temp_ext_attrib_val_hist_tbl(l_ind);
            x_index := x_index +1;
          end if;
        END LOOP;
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    x_index := 1;
    BEGIN
      SELECT 'x'
      INTO   l_dummy
      FROM   csi_ii_relationships_h
      WHERE  transaction_id = p_transaction_id
      AND    rownum=1;

      csi_ii_relationships_pvt.get_inst_relationship_hist
       ( p_api_version              => 1.0
        ,p_commit                   => fnd_api.g_false
        ,p_init_msg_list            => fnd_api.g_false
        ,p_validation_level         => fnd_api.g_valid_level_full
        ,p_transaction_id           => p_transaction_id
        ,x_rel_history_tbl          => temp_rel_history_tbl
        ,x_return_status            => x_return_status
        ,x_msg_count                => x_msg_count
        ,x_msg_data                 => x_msg_data
       );

       IF temp_rel_history_tbl.count > 0 THEN
        FOR l_ind IN temp_rel_history_tbl.FIRST .. temp_rel_history_tbl.LAST
        LOOP
          if (temp_rel_history_tbl(l_ind).object_id = p_instance_id) then
            x_rel_history_tbl(x_index) := temp_rel_history_tbl(l_ind);
            x_index := x_index +1;
          end if;
        END LOOP;
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
/*
    BEGIN
      SELECT 'x'
      INTO   l_dummy
      FROM   csi_i_version_labels_h
      WHERE  transaction_id = p_transaction_id
      AND    ROWNUM = 1;

      csi_item_instance_pvt.get_version_label_history
       ( p_api_version              => 1.0
        ,p_commit                   => fnd_api.g_false
        ,p_init_msg_list            => fnd_api.g_false
        ,p_validation_level         => fnd_api.g_valid_level_full
        ,p_transaction_id           => p_transaction_id
        ,x_version_label_hist_tbl   => x_version_label_hist_tbl
        ,x_return_status            => x_return_status
        ,x_msg_count                => x_msg_count
        ,x_msg_data                 => x_msg_data
       );

    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
*/
    -- End of API body

        -- Standard check of p_commit.
        IF FND_API.To_Boolean( p_commit ) THEN
                COMMIT WORK;
        END IF;
   /** bug 3304439
    -- Check for the profile option and disable the trace
        IF (fnd_profile.value('CSI_ENABLE_SQL_TRACE') = 'Y') THEN
                   dbms_session.set_sql_trace(false);
    END IF;
   **/
        -- End disable trace

        -- Standard call to get message count and if count is  get message info.
        FND_MSG_PUB.Count_And_Get
                (p_count        =>      x_msg_count ,
             p_data     =>      x_msg_data      );
EXCEPTION
        WHEN OTHERS THEN
                X_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF fnd_api.to_boolean(p_commit)
                THEN
                ROLLBACK TO get_history_transactions;
                END IF;
                IF FND_MSG_PUB.Check_Msg_Level
                     (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                   FND_MSG_PUB.Add_Exc_Msg
                    ( G_PKG_NAME, l_api_name );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (       p_count         =>      x_msg_count,
                        p_data      =>      x_msg_data);

END get_history_transactions ;

Procedure CSI_CONFIG_LAUNCH_PRMS
(	p_api_version	IN 	NUMBER,
	p_init_msg_list	IN	VARCHAR2,
	p_commit	IN	VARCHAR2,
	p_validation_level	IN  	NUMBER,
	x_return_status	OUT	NOCOPY VARCHAR2,
	x_msg_count	OUT	NOCOPY NUMBER,
	x_msg_data	OUT	NOCOPY VARCHAR2,
	x_configurable	OUT 	NOCOPY VARCHAR2,
	x_icx_sessn_tkt	OUT	NOCOPY VARCHAR2,
	x_db_id		OUT	NOCOPY VARCHAR2,
	x_servlet_url	OUT	NOCOPY VARCHAR2,
	x_sysdate	OUT	NOCOPY VARCHAR2
) is
	l_api_name	CONSTANT VARCHAR2(30)	:= 'Get_Config_Launch_Info';
	l_api_version	CONSTANT NUMBER		:= 1.0;

	l_resp_id		NUMBER;
	l_resp_appl_id		NUMBER;
	l_user_id	NUMBER;

BEGIN
	l_user_id := fnd_global.user_id;

	SAVEPOINT	CSI_CONFIG_LAUNCH_PRMS;
	-- Standard call to check for call compatibility.
	/*IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;*/

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;

	-- Initialize API rturn status to success
	x_return_status := FND_API.g_ret_sts_success;


	l_resp_id := fnd_profile.value('RESP_ID');
	l_resp_appl_id := fnd_profile.value('RESP_APPL_ID');

	-- get icx session ticket
	x_icx_sessn_tkt := CZ_CF_API.ICX_SESSION_TICKET;

	-- get the dbc file name
	x_db_id := FND_WEB_CONFIG.DATABASE_ID;

	-- get the URL for servlet
	x_servlet_url := fnd_profile.value('CZ_UIMGR_URL');

	-- get the SYSDATE
	x_sysdate := to_char(sysdate,'mm-dd-yyyy-hh24-mi-ss');


	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;
	FND_MSG_PUB.Count_And_Get
    	(  	p_encoded 		=> FND_API.G_FALSE,
    		p_count         =>      x_msg_count,
        	p_data          =>      x_msg_data
    	);
EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO CSI_CONFIG_LAUNCH_PRMS;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_encoded 		=> FND_API.G_FALSE,
			    p_count        	=>      x_msg_count,
        		p_data         	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		csi_gen_utility_pvt.put_line('ibe_cfg_config_pvt.Get_Config_Launch_Info: UNEXPECTED ERROR EXCEPTION ');
		ROLLBACK TO Get_Config_Launch_Info_Pvt;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_encoded 		=> FND_API.G_FALSE,
			    p_count        	=>      x_msg_count,
       			p_data         	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		csi_gen_utility_pvt.put_line('ibe_cfg_config_pvt.Get_Config_Launch_Info: OTHER EXCEPTION ');
		ROLLBACK TO Get_Config_Launch_Info_Pvt;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		/*IF 	FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME,
    	    			l_api_name
	    		);
		END IF;*/
		FND_MSG_PUB.Count_And_Get
    		(  	p_encoded 		=> FND_API.G_FALSE,
			    p_count        	=>      x_msg_count,
       			p_data         	=>      x_msg_data
    		);
		/*ibe_util.disable_debug;*/
END; -- Procedure CSI_CONFIG_LAUNCH_PRMS



PROCEDURE IS_CONFIGURABLE(p_api_version     IN   NUMBER
                         ,p_config_hdr_id   IN   NUMBER
                         ,p_config_rev_nbr  IN   NUMBER
                         ,p_config_item_id  IN   NUMBER
                         ,x_return_value    OUT  NOCOPY VARCHAR2
                         ,x_return_status   OUT  NOCOPY VARCHAR2
                         ,x_msg_count       OUT  NOCOPY NUMBER
                         ,x_msg_data        OUT  NOCOPY VARCHAR2
                         ) IS
BEGIN
    cz_network_api_pub.IS_CONFIGURABLE(p_api_version
                         ,p_config_hdr_id
                         ,p_config_rev_nbr
                         ,p_config_item_id
                         ,x_return_value
                         ,x_return_status
                         ,x_msg_count
                         ,x_msg_data);
/*EXCEPTION
   WHEN exception_name THEN
       statements ;*/
END;

PROCEDURE get_instance_link_locations
 (
      p_api_version          IN  NUMBER
     ,p_commit               IN  VARCHAR2
     ,p_init_msg_list        IN  VARCHAR2
     ,p_validation_level     IN  NUMBER
     ,p_instance_id          IN  NUMBER
     ,x_instance_link_rec    OUT NOCOPY csi_datastructures_pub.instance_link_rec
     ,x_return_status        OUT NOCOPY VARCHAR2
     ,x_msg_count            OUT NOCOPY NUMBER
     ,x_msg_data             OUT NOCOPY VARCHAR2
    )
IS
    l_api_name               CONSTANT VARCHAR2(30)   := 'GET_INSTANCE_LINK_LOCATIONS';
    l_api_version            CONSTANT NUMBER         := 1.0;
    l_debug_level            NUMBER;
    --l_instance_header_tbl    csi_datastructures_pub.instance_header_tbl;

BEGIN
	SAVEPOINT  get_instance_link_location;

  csi_item_instance_pvt.get_instance_link_locations(
     p_api_version
     ,p_commit
     ,p_init_msg_list
     ,p_validation_level
     ,p_instance_id
     ,x_instance_link_rec
     ,x_return_status
     ,x_msg_count
     ,x_msg_data
     );

	FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
	     p_data  => x_msg_data
		);

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		ROLLBACK TO get_instance_link_location;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count => x_msg_count,
        		p_data  => x_msg_data
    		);

  	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		ROLLBACK TO get_instance_link_location;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count => x_msg_count,
        		p_data  => x_msg_data
    		);

   	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		ROLLBACK TO get_instance_link_location;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
   	    	FND_MSG_PUB.Add_Exc_Msg
   	    	(G_PKG_NAME,
    	     l_api_name
	    	);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);

END get_instance_link_locations;


Procedure bld_data_for_conn_rec
(
  p_connected_relationship_tbl in out NOCOPY connected_relationship_tbl,
  p_rel_tbl1 in csi_datastructures_pub.ii_relationship_tbl,
  p_instanceid_tbl in out NOCOPY instanceid_tbl,
  p_instanceid_tbl1 in out NOCOPY instanceid_tbl1,
  i in number
)
is
temp number;
count1 number;
begin
    count1 := p_instanceid_tbl1.count + 1;
    p_connected_relationship_tbl(i).object_id := p_rel_tbl1(i).object_id;
    p_connected_relationship_tbl(i).subject_id := p_rel_tbl1(i).subject_id;
    p_connected_relationship_tbl(i).swapflag := 'N';
    temp := p_rel_tbl1(i).object_id;
    if p_instanceid_tbl.exists(temp) then
        null;
    else
        p_instanceid_tbl(temp) := p_rel_tbl1(i).object_id;
        p_instanceid_tbl1(count1).instance_id := p_rel_tbl1(i).object_id;
        count1 := count1 + 1;
    end if;
    temp := p_rel_tbl1(i).subject_id;
    if p_instanceid_tbl.exists(temp) then
        null;
    else
        p_instanceid_tbl(temp) := p_rel_tbl1(i).subject_id;
        p_instanceid_tbl1(count1).instance_id := p_rel_tbl1(i).subject_id;
        count1 := count1 + 1;
    end if;
end bld_data_for_conn_rec;


Procedure modify_data_for_conn_relship
(
  p_connected_relationship_tbl in out NOCOPY connected_relationship_tbl,
  p_instanceid_tbl1 in out NOCOPY instanceid_tbl1

) is
temp number;
begin
    for outer in p_instanceid_tbl1.first..p_instanceid_tbl1.last
       loop
        for inner in p_connected_relationship_tbl.first..p_connected_relationship_tbl.last
        loop
         if p_connected_relationship_tbl(inner).swapflag = 'N'
           and p_connected_relationship_tbl(inner).object_id =   p_instanceid_tbl1(outer).instance_id
           then
           p_connected_relationship_tbl(inner).swapflag := 'Y';
         end if;
        end loop;
        for inner in p_connected_relationship_tbl.first..p_connected_relationship_tbl.last
        loop
         if p_connected_relationship_tbl(inner).swapflag = 'N'
           and p_connected_relationship_tbl(inner).subject_id =   p_instanceid_tbl1(outer).instance_id
           then
           temp := p_connected_relationship_tbl(inner).object_id;
           p_connected_relationship_tbl(inner).object_id := p_connected_relationship_tbl(inner).subject_id;
           p_connected_relationship_tbl(inner).subject_id := temp;
           p_connected_relationship_tbl(inner).swapflag := 'Y';
         end if;
        end loop;
       end loop;
       for i in p_connected_relationship_tbl.first .. p_connected_relationship_tbl.last
       loop
        insert into csi_configuration_temp_tbl (object_id,subject_id) values ( p_connected_relationship_tbl(i).object_id, p_connected_relationship_tbl(i).subject_id);
       end loop;

end modify_data_for_conn_relship;

Procedure bld_instance_all_parents_tbl
    (
        p_subject_id      IN  NUMBER,
        p_relationship_type_code IN VARCHAR2,
        p_time_stamp IN DATE
    ) IS
    l_api_version             number      := 1.0;
    l_commit                  varchar2(1) := fnd_api.g_false;
    l_init_msg_list           varchar2(1) := fnd_api.g_false;
    l_validation_level        number      := fnd_api.g_valid_level_full;
    l_rel_tbl               csi_datastructures_pub.ii_relationship_tbl;
    l_rel_tbl1               csi_datastructures_pub.ii_relationship_tbl;
    l_msg_count               number;
    l_msg_data                varchar2(240);
    l_return_status           varchar2(1) := fnd_api.g_ret_sts_success;
    l_depth                    NUMBER := null;
    l_relationship_query_rec    csi_datastructures_pub.relationship_query_rec;
    l_relationship_query_rec1    csi_datastructures_pub.relationship_query_rec;
    l_all_parents_id         varchar2(4000);
    l_time_stamp  DATE := p_time_stamp;
    l_active_relationship_only    VARCHAR2(1) := fnd_api.g_true; --fix for bug5222952
	l_var integer;
	l_connected_relationship_tbl connected_relationship_tbl;
	l_instanceid_tbl instanceid_tbl;
	l_instanceid_tbl1 instanceid_tbl1;
BEGIN
  l_relationship_query_rec.Subject_id:=p_subject_id ;
  l_relationship_query_rec.relationship_type_code:= p_relationship_type_code;
  delete from csi_configuration_temp_tbl;
  if p_relationship_type_code <> 'CONNECTED-TO' then
      LOOP
      csi_ii_relationships_pub.get_relationships
      (
        l_api_version,
         l_commit,
         l_init_msg_list,
         l_validation_level,
         l_relationship_query_rec,
         l_depth,
         l_time_stamp,
         l_active_relationship_only,
         l_rel_tbl,
         l_return_status,
         l_msg_count,
         l_msg_data
       );
       if l_rel_tbl.count > 0 then
          l_var := l_rel_tbl.first;
          insert into csi_configuration_temp_tbl
            (
            object_id,
            subject_id
        )
        values
        (
            l_rel_tbl(l_var).object_id,
            l_rel_tbl(l_var).subject_id
        );

	  l_relationship_query_rec.Subject_id := l_rel_tbl(l_var).object_id;
   else
	  exit;
   end if;
  END LOOP;
  else
    --put selected instanceid_rec by default in validation array
    l_instanceid_tbl(1) := p_subject_id;
    l_instanceid_tbl1(1).instance_id := p_subject_id;
  end if;
  -- Now construct childs of actual input
  l_relationship_query_rec1.object_id:=p_subject_id ;
  l_relationship_query_rec1.relationship_type_code:= p_relationship_type_code;
  csi_ii_relationships_pub.get_relationships
   (
     l_api_version,
     l_commit,
     l_init_msg_list,
     l_validation_level,
     l_relationship_query_rec1,
     l_depth,
     l_time_stamp,
     l_active_relationship_only,
     l_rel_tbl1,
     l_return_status,
     l_msg_count,
     l_msg_data
   );
   if l_rel_tbl1.count > 0 then
    for i in l_rel_tbl1.first .. l_rel_tbl1.last
    loop
      if p_relationship_type_code = 'CONNECTED-TO' then
        bld_data_for_conn_rec(
                              p_connected_relationship_tbl => l_connected_relationship_tbl,
                              p_rel_tbl1 => l_rel_tbl1,
                              p_instanceid_tbl => l_instanceid_tbl,
                              p_instanceid_tbl1 => l_instanceid_tbl1,
                              i => i);
      else
        insert into csi_configuration_temp_tbl (object_id,subject_id) values ( l_rel_tbl1(i).object_id, l_rel_tbl1(i).subject_id);
      end if;
   end loop;
   end if;
   if p_relationship_type_code = 'CONNECTED-TO' then
       if l_connected_relationship_tbl.count > 0 then
	       modify_data_for_conn_relship(
                    p_connected_relationship_tbl => l_connected_relationship_tbl,
                    p_instanceid_tbl1 => l_instanceid_tbl1);
       end if;
   end if;
END bld_instance_all_parents_tbl;


FUNCTION get_instance_all_parents
    (
        p_subject_id      IN  NUMBER,
        p_time_stamp IN DATE
    ) RETURN VARCHAR2 IS
    l_api_version             number      := 1.0;
    l_commit                  varchar2(1) := fnd_api.g_false;
    l_init_msg_list           varchar2(1) := fnd_api.g_false;
    l_validation_level        number      := fnd_api.g_valid_level_full;
    l_rel_tbl               csi_datastructures_pub.ii_relationship_tbl;
    l_msg_count               number;
    l_msg_data                varchar2(240);
    l_return_status           varchar2(1) := fnd_api.g_ret_sts_success;
    l_depth                    NUMBER := null;
    l_relationship_query_rec    csi_datastructures_pub.relationship_query_rec;
    l_all_parents_id         varchar2(4000);
    l_time_stamp  DATE :=p_time_stamp;
    l_active_relationship_only    VARCHAR2(1) := fnd_api.g_true;
	l_output varchar2(4000);
	l_var integer;
BEGIN
  l_relationship_query_rec.Subject_id:=p_subject_id ;
  l_output :=  p_subject_id ;

   LOOP

    l_relationship_query_rec.relationship_type_code:='COMPONENT-OF';


   csi_ii_relationships_pub.get_relationships
   (
     l_api_version,
     l_commit,
     l_init_msg_list,
     l_validation_level,
     l_relationship_query_rec,
     l_depth,
     l_time_stamp,
     l_active_relationship_only,
     l_rel_tbl,
     l_return_status,
     l_msg_count,
     l_msg_data
   );
   if l_rel_tbl.count > 0 then
      l_var := l_rel_tbl.first;
      l_output := to_char(l_rel_tbl(l_var).object_id) || ',' || l_output;
	  l_relationship_query_rec.Subject_id := l_rel_tbl(l_var).object_id;
   else
	  exit;
   end if;
  END LOOP;
  return l_output;
END;
/* Function added to get the Item Validation Org Id for the Configurator Flow */

FUNCTION get_config_org_id(
p_instance_id IN NUMBER,
p_last_oe_order_line_id IN NUMBER)
RETURN VARCHAR2 IS
l_org_id NUMBER := -1;
l_config_id VARCHAR2(100) := '-1';
BEGIN

BEGIN
SELECT
    org_id into l_org_id
FROM
    oe_order_lines_all oeol
WHERE
    line_id=p_last_oe_order_line_id;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
   l_org_id:=-1;
END;

IF l_org_id <> -1 THEN
    mo_global.set_policy_context('S',l_org_id);

    SELECT
        oe_sys_parameters.value('MASTER_ORGANIZATION_ID', l_org_id)
    INTO l_config_id
    FROM DUAL;

END IF;

Return l_config_id;

END;




/* Function to get new non serial instances for deployment */

FUNCTION get_instance_ids
    (
       P_instance_tbl      IN OUT NOCOPY  dpl_instance_tbl

    ) RETURN VARCHAR2 IS

l_output varchar2(4000):='';
l_instance_id NUMBER;
n_instance_id NUMBER;
found_flag varchar2(1) :='N';

CURSOR c_item_instances(l_instance_id NUMBER)  IS
    SELECT serial_number
    FROM   csi_item_instances
    WHERE  instance_id =l_instance_id ;

CURSOR  c_nsrl_item_instances(n_instance_id NUMBER) IS
   SELECT CIIH.INSTANCE_ID FROM
   CSI_ITEM_INSTANCES_H ciih,
   csi_item_instances cii
   WHERE
   cii.instance_id =ciih.instance_id
   AND cii.SERIAL_NUMBER IS  NULL
    and  ciiH.INSTANCE_ID NOT IN n_instance_id
   AND  TRANSACTION_ID IN
   ( SELECT MAX(TRANSACTION_ID) FROM CSI_ITEM_INSTANCES_H WHERE INSTANCE_ID
    = n_instance_id);

BEGIN

For idx in P_instance_tbl.first..P_instance_tbl.last

LOOP
      For c_rec in c_item_instances(P_instance_tbl(idx).instance_id)

      LOOP

         IF C_REC.SERIAL_NUMBER IS  NOT NULL THEN

              IF (l_output='' OR l_output IS NULL) THEN
                l_output :=to_char(P_instance_tbl(idx).instance_id);
              ELSE
                l_output := l_output||','||to_char(P_instance_tbl(idx).instance_id) ;
              END IF;

         END IF;
        END LOOP;
END LOOP;



N_instance_id :=P_instance_tbl(1).instance_id;

FOR c_rec in c_nsrl_item_instances(N_instance_id)
        LOOP
            found_flag :='N';
        FOR i_dx in P_instance_tbl.first..P_instance_tbl.last
        LOOP
            IF c_rec.instance_id=p_instance_tbl(i_dx).instance_id  THEN
		found_flag :='Y';
		--p_instance_tbl.DELETE(i_dx);
		EXIT;
	   END IF;
        END LOOP;

	IF Found_flag='N' THEN

		IF (l_output='' OR l_output IS NULL) THEN
	          l_output :=to_char(c_rec.instance_id);
                ELSE
                 l_output := l_output||','||to_char(c_rec.instance_id) ;
                END IF;
        END IF;
END LOOP;


RETURN l_output;
END;



PROCEDURE get_contact_details
 (
      p_api_version                 IN  NUMBER
     ,p_commit                      IN  VARCHAR2
     ,p_init_msg_list               IN  VARCHAR2
     ,p_validation_level            IN  NUMBER
     ,p_contact_party_id            IN  NUMBER
     ,p_contact_flag                IN  VARCHAR2
     ,p_party_tbl                   IN  VARCHAR2
     ,x_contact_details             OUT NOCOPY  csi_datastructures_pub.contact_details_rec
     ,x_return_status               OUT NOCOPY  VARCHAR2
     ,x_msg_count                   OUT NOCOPY  NUMBER
     ,x_msg_data                    OUT NOCOPY  VARCHAR2
    )
 IS
begin
    csi_party_relationships_pvt.get_contact_details
    (
      p_api_version
     ,p_commit
     ,p_init_msg_list
     ,p_validation_level
     ,p_contact_party_id
     ,p_contact_flag
     ,p_party_tbl
     ,x_contact_details
     ,x_return_status
     ,x_msg_count
     ,x_msg_data
    );

End get_contact_details;

PROCEDURE delete_search_oks_temp
 (
        p_sequence_id          IN  NUMBER
       ,x_return_status        OUT NOCOPY VARCHAR2
       ,x_msg_count            OUT NOCOPY NUMBER
       ,x_msg_data             OUT NOCOPY VARCHAR2
 ) IS

    l_api_name               CONSTANT VARCHAR2(30)   := 'delete_search_oks_temp';

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS ;

  IF p_sequence_id IS NULL THEN
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count,
       p_data  => x_msg_data
      );
  ELSE
     DELETE csi_search_oks_temp where id = p_sequence_id ;
     COMMIT;
  END IF;

EXCEPTION
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       IF  FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
          FND_MSG_PUB.Add_Exc_Msg
          (G_PKG_NAME,
           l_api_name
          );
       END IF;
       FND_MSG_PUB.Count_And_Get
       ( p_count  =>     x_msg_count,
         p_data   =>     x_msg_data
       );
END delete_search_oks_temp;

PROCEDURE expire_relationship
 (
      p_api_version             IN NUMBER
      ,p_commit                 IN VARCHAR2
      ,p_init_msg_list          IN VARCHAR2
      ,p_validation_level       IN NUMBER
      ,p_subject_id             IN NUMBER
      ,p_txn_rec                IN  OUT NOCOPY csi_datastructures_pub.transaction_rec
      ,x_instance_id_lst            OUT NOCOPY csi_datastructures_pub.id_tbl
      ,x_return_status              OUT NOCOPY VARCHAR2
      ,x_msg_count                  OUT NOCOPY NUMBER
      ,x_msg_data                   OUT NOCOPY VARCHAR2
 ) IS
    l_relationship_id       NUMBER;
    l_object_version_number NUMBER;
    l_relationship_rec      csi_datastructures_pub.ii_relationship_rec;
BEGIN
    SELECT
        relationship_id, object_version_number INTO l_relationship_id, l_object_version_number
    FROM
        csi_ii_relationships
    WHERE
        subject_id = p_subject_id
        and (active_end_date IS NULL OR active_end_date > sysdate);

    l_relationship_rec.relationship_id := l_relationship_id;
    l_relationship_rec.object_version_number := l_object_version_number;

    CSI_II_RELATIONSHIPS_PUB.expire_relationship
     (
         p_api_version        =>    p_api_version,
         p_commit             =>    p_commit,
         p_init_msg_list      =>    p_init_msg_list,
         p_validation_level   =>    p_validation_level,
         p_relationship_rec   =>    l_relationship_rec,
         p_txn_rec            =>    p_txn_rec,
         x_instance_id_lst    =>    x_instance_id_lst,
         x_return_status      =>    x_return_status,
         x_msg_count          =>    x_msg_count,
         x_msg_data           =>    x_msg_data
     );
END expire_relationship;

END CSI_JAVA_INTERFACE_PKG;

/
