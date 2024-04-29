--------------------------------------------------------
--  DDL for Package Body CSI_COUNTER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_COUNTER_PUB" AS
/* $Header: csipctib.pls 120.10.12010000.4 2008/11/07 18:50:31 mashah ship $ */

-- --------------------------------------------------------
-- Define global variables
-- --------------------------------------------------------

G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSI_COUNTER_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csipctib.pls';

--|---------------------------------------------------
--| procedure name: create_counter
--| description :   procedure used to
--|                 create counter instance
--|---------------------------------------------------

PROCEDURE create_counter
 (
     p_api_version	             IN	NUMBER
    ,p_init_msg_list	          	IN	VARCHAR2
    ,p_commit		                 IN	VARCHAR2
    ,p_validation_level          IN NUMBER
    ,p_counter_instance_rec	    IN out	NOCOPY CSI_CTR_DATASTRUCTURES_PUB.Counter_instance_rec
    ,P_ctr_properties_tbl       IN out NOCOPY CSI_CTR_DATASTRUCTURES_PUB.Ctr_properties_tbl
    ,P_counter_relationships_tbl IN out NOCOPY CSI_CTR_DATASTRUCTURES_PUB.counter_relationships_tbl
    ,P_ctr_derived_filters_tbl  IN out NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_derived_filters_tbl
    ,P_counter_associations_tbl IN out NOCOPY CSI_CTR_DATASTRUCTURES_PUB.counter_associations_tbl
    ,x_return_status               out NOCOPY VARCHAR2
    ,x_msg_count                   out NOCOPY NUMBER
    ,x_msg_data                    out NOCOPY VARCHAR2
    ,x_ctr_id		           out	NOCOPY NUMBER
 )
 IS
    l_api_name                      CONSTANT VARCHAR2(30)   := 'CREATE_COUNTER';
    l_api_version                   CONSTANT NUMBER         := 1.0;
    -- l_debug_level                   NUMBER;
    l_flag                          VARCHAR2(1)             := 'N';
    l_msg_data                      VARCHAR2(2000);
    l_msg_index                     NUMBER;
    l_msg_count                     NUMBER;
    l_count                         NUMBER;
    l_return_message                VARCHAR2(100);

    l_counter_id                    NUMBER;
    l_Ctr_properties_rec            CSI_CTR_DATASTRUCTURES_PUB.Ctr_properties_rec;
    l_counter_relationships_rec     CSI_CTR_DATASTRUCTURES_PUB.counter_relationships_rec;
    l_ctr_derived_filters_rec       CSI_CTR_DATASTRUCTURES_PUB.ctr_derived_filters_rec;
    l_counter_associations_rec      CSI_CTR_DATASTRUCTURES_PUB.counter_associations_rec;

    -- Added for inserting initial reading
    l_c_ind_txn                  BINARY_INTEGER := 0;
    l_c_ind_rdg                  BINARY_INTEGER := 0;
    l_c_ind_prop                 BINARY_INTEGER := 0;
    l_transaction_type_id        NUMBER;
    l_transaction_tbl   csi_datastructures_pub.transaction_tbl;
    l_counter_readings_tbl       csi_ctr_datastructures_pub.counter_readings_tbl;
    l_ctr_property_readings_tbl  csi_ctr_datastructures_pub.ctr_property_readings_tbl;
    l_src_obj_cd   VARCHAR2(30);
    l_src_obj_id   NUMBER;
    CURSOR DFLT_PROP_RDG(p_counter_id IN NUMBER) IS
    SELECT ccp.counter_property_id,ccp.default_value,ccp.property_data_type, ccp.is_nullable
    FROM CSI_COUNTER_PROPERTIES_B ccp
    WHERE ccp.counter_id = p_counter_id AND NVL(ccp.is_nullable,'N') = 'N'
    AND   NVL(end_date_active,(SYSDATE+1)) > SYSDATE;

    l_rel_type  VARCHAR2(30) := 'CONFIGURATION';


BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  create_counter_pub;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   -- Check the profile option debug_level for debug message reporting
   -- l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

   -- If debug_level = 1 then dump the procedure name
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'create_counter');
   END IF;

   -- If the debug level = 2 then dump all the parameters values.
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 1) THEN
      csi_ctr_gen_utility_pvt.put_line( 'create_counter'     ||
                                     p_api_version         ||'-'||
                                     p_commit              ||'-'||
                                     p_init_msg_list       ||'-'||
                                     p_validation_level );
      csi_ctr_gen_utility_pvt.dump_counter_instance_rec(p_counter_instance_rec);
   END IF;

   /* Customer pre -processing  section - Mandatory  */
   IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'C' )  ) THEN
     CSI_COUNTER_CUHK.create_counter_pre
     (
      p_api_version	            => p_api_version
      ,p_init_msg_list	            => p_init_msg_list
      ,p_commit		            => p_commit
      ,p_validation_level           => p_validation_level
      ,p_counter_instance_rec	    => p_counter_instance_rec
      ,P_ctr_properties_tbl         => P_ctr_properties_tbl
      ,P_counter_relationships_tbl  => P_counter_relationships_tbl
      ,P_ctr_derived_filters_tbl    => P_ctr_derived_filters_tbl
      ,P_counter_associations_tbl   => P_counter_associations_tbl
      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
      ,x_ctr_id		            => x_ctr_id
     );
     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;

          WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                            FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_CUHK.CREATE_COUNTER_PRE API');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
          END LOOP;
          RAISE FND_API.G_EXC_ERROR;
       END IF;


   END IF;
   /* Vertical pre -processing  section - Mandatory  */
   IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' )  ) THEN
     CSI_COUNTER_VUHK.create_counter_pre
     (
      p_api_version	            => p_api_version
      ,p_init_msg_list	            => p_init_msg_list
      ,p_commit		            => p_commit
      ,p_validation_level           => p_validation_level
      ,p_counter_instance_rec	    => p_counter_instance_rec
      ,P_ctr_properties_tbl         => P_ctr_properties_tbl
      ,P_counter_relationships_tbl  => P_counter_relationships_tbl
      ,P_ctr_derived_filters_tbl    => P_ctr_derived_filters_tbl
      ,P_counter_associations_tbl   => P_counter_associations_tbl
      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
      ,x_ctr_id		            => x_ctr_id
     );
     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;

          WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                            FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_VUHK.CREATE_COUNTER_PRE API');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
          END LOOP;
          RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;

   -- Start of API Body
/*
   IF P_counter_associations_tbl.COUNT = 0 THEN
      csi_ctr_gen_utility_pvt.put_line('Counter Associations Information is empty. Cannot Proceed...');
      csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_NO_CTR_ASSOC_ID');
   END IF;
*/
   CSI_COUNTER_PVT.create_counter
   (
     p_api_version	    =>	1.0
    ,p_init_msg_list	    =>	p_init_msg_list
    ,p_commit		    =>	p_commit
    ,p_validation_level	    =>	p_validation_level
    ,p_counter_instance_rec => p_counter_instance_rec
    ,x_return_status	    =>	x_return_status
    ,x_msg_count	    =>	x_msg_count
    ,x_msg_data		    =>	x_msg_data
    ,x_ctr_id		    =>	l_counter_id
    );
    IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          l_msg_index := 1;
          l_msg_count := x_msg_count;

          WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                            FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_PVT.CREATE_COUNTER API');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
          END LOOP;
          RAISE FND_API.G_EXC_ERROR;
     END IF;

    x_ctr_id := l_counter_id;

    -- Insert Counter Properties
    IF p_ctr_properties_tbl.count > 0 THEN
       FOR j in p_ctr_properties_tbl.FIRST..p_ctr_properties_tbl.LAST
       LOOP
          DECLARE
             l_ctr_property_id NUMBER;
          BEGIN
             l_Ctr_properties_rec.counter_id := l_counter_id;
             l_Ctr_properties_rec.NAME := p_ctr_properties_tbl(j).name;
             l_Ctr_properties_rec.DESCRIPTION  := p_ctr_properties_tbl(j).DESCRIPTION;
             l_Ctr_properties_rec.PROPERTY_DATA_TYPE := p_ctr_properties_tbl(j).PROPERTY_DATA_TYPE;
             l_Ctr_properties_rec.IS_NULLABLE  := p_ctr_properties_tbl(j).IS_NULLABLE;
             l_Ctr_properties_rec.DEFAULT_VALUE  := p_ctr_properties_tbl(j).DEFAULT_VALUE;
             l_Ctr_properties_rec.MINIMUM_VALUE  := p_ctr_properties_tbl(j).MINIMUM_VALUE;
             l_Ctr_properties_rec.MAXIMUM_VALUE  := p_ctr_properties_tbl(j).MAXIMUM_VALUE;
             l_Ctr_properties_rec.UOM_CODE       := p_ctr_properties_tbl(j).UOM_CODE;
             l_Ctr_properties_rec.START_DATE_ACTIVE  := p_ctr_properties_tbl(j).START_DATE_ACTIVE;
             l_Ctr_properties_rec.END_DATE_ACTIVE    := p_ctr_properties_tbl(j).END_DATE_ACTIVE;
             l_Ctr_properties_rec.PROPERTY_LOV_TYPE  := p_ctr_properties_tbl(j).PROPERTY_LOV_TYPE;
             l_Ctr_properties_rec.ATTRIBUTE1     := p_ctr_properties_tbl(j).ATTRIBUTE1;
             l_Ctr_properties_rec.ATTRIBUTE2     := p_ctr_properties_tbl(j).ATTRIBUTE2;
             l_Ctr_properties_rec.ATTRIBUTE3     := p_ctr_properties_tbl(j).ATTRIBUTE3;
             l_Ctr_properties_rec.ATTRIBUTE4     := p_ctr_properties_tbl(j).ATTRIBUTE4;
             l_Ctr_properties_rec.ATTRIBUTE5     := p_ctr_properties_tbl(j).ATTRIBUTE5;
             l_Ctr_properties_rec.ATTRIBUTE6     := p_ctr_properties_tbl(j).ATTRIBUTE6;
             l_Ctr_properties_rec.ATTRIBUTE7     := p_ctr_properties_tbl(j).ATTRIBUTE7;
             l_Ctr_properties_rec.ATTRIBUTE8     := p_ctr_properties_tbl(j).ATTRIBUTE8;
             l_Ctr_properties_rec.ATTRIBUTE9     := p_ctr_properties_tbl(j).ATTRIBUTE9;
             l_Ctr_properties_rec.ATTRIBUTE10    := p_ctr_properties_tbl(j).ATTRIBUTE10;
             l_Ctr_properties_rec.ATTRIBUTE11    := p_ctr_properties_tbl(j).ATTRIBUTE11;
             l_Ctr_properties_rec.ATTRIBUTE12    := p_ctr_properties_tbl(j).ATTRIBUTE12;
             l_Ctr_properties_rec.ATTRIBUTE13    := p_ctr_properties_tbl(j).ATTRIBUTE13;
             l_Ctr_properties_rec.ATTRIBUTE14    := p_ctr_properties_tbl(j).ATTRIBUTE14;
             l_Ctr_properties_rec.ATTRIBUTE15    := p_ctr_properties_tbl(j).ATTRIBUTE15;
             l_Ctr_properties_rec.ATTRIBUTE_CATEGORY  := p_ctr_properties_tbl(j).ATTRIBUTE_CATEGORY;


             CSI_COUNTER_PVT.create_ctr_property
           	 (
           	   p_api_version	=>	1.0
           	  ,p_init_msg_list	=>	p_init_msg_list
           	  ,p_commit		=>	p_commit
           	  ,p_validation_level	=>	p_validation_level
                  ,p_ctr_properties_rec =>      l_Ctr_properties_rec
           	  ,x_return_status	=>	x_return_status
           	  ,x_msg_count	        =>	x_msg_count
           	  ,x_msg_data		=>	x_msg_data
           	  ,x_ctr_property_id	=>	l_ctr_property_id
           	  );
          	   IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                l_msg_index := 1;
                l_msg_count := x_msg_count;

                WHILE l_msg_count > 0 LOOP
                 x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                            FND_API.G_FALSE );
                 csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_PVT.CREATE_CTR_PROPERTY API');
                 csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                 l_msg_index := l_msg_index + 1;
                 l_msg_count := l_msg_count - 1;
                END LOOP;
                RAISE FND_API.G_EXC_ERROR;
              END IF;
          END;
       END LOOP;
    END IF;

    -- Insert Counter relationships
    IF P_counter_relationships_tbl.count > 0 THEN
       FOR i in p_counter_relationships_tbl.FIRST..p_counter_relationships_tbl.LAST
       LOOP
          DECLARE
             l_relationship_id NUMBER;
          BEGIN
             l_counter_relationships_rec.OBJECT_COUNTER_ID  := l_counter_id;
             l_counter_relationships_rec.CTR_ASSOCIATION_ID := p_counter_relationships_tbl(i).CTR_ASSOCIATION_ID;
             l_counter_relationships_rec.RELATIONSHIP_TYPE_CODE := p_counter_relationships_tbl(i).RELATIONSHIP_TYPE_CODE;
             l_counter_relationships_rec.SOURCE_COUNTER_ID  := p_counter_relationships_tbl(i).SOURCE_COUNTER_ID;
             l_counter_relationships_rec.ACTIVE_START_DATE  := p_counter_relationships_tbl(i).ACTIVE_START_DATE ;
             l_counter_relationships_rec.ACTIVE_END_DATE  := p_counter_relationships_tbl(i).ACTIVE_END_DATE;
             l_counter_relationships_rec.BIND_VARIABLE_NAME  := p_counter_relationships_tbl(i).BIND_VARIABLE_NAME;
             l_counter_relationships_rec.FACTOR  := p_counter_relationships_tbl(i).FACTOR;
             l_counter_relationships_rec.ATTRIBUTE1     := p_counter_relationships_tbl(i).ATTRIBUTE1;
             l_counter_relationships_rec.ATTRIBUTE2     := p_counter_relationships_tbl(i).ATTRIBUTE2;
             l_counter_relationships_rec.ATTRIBUTE3     := p_counter_relationships_tbl(i).ATTRIBUTE3;
             l_counter_relationships_rec.ATTRIBUTE4     := p_counter_relationships_tbl(i).ATTRIBUTE4;
             l_counter_relationships_rec.ATTRIBUTE5     := p_counter_relationships_tbl(i).ATTRIBUTE5;
             l_counter_relationships_rec.ATTRIBUTE6     := p_counter_relationships_tbl(i).ATTRIBUTE6;
             l_counter_relationships_rec.ATTRIBUTE7     := p_counter_relationships_tbl(i).ATTRIBUTE7;
             l_counter_relationships_rec.ATTRIBUTE8     := p_counter_relationships_tbl(i).ATTRIBUTE8;
             l_counter_relationships_rec.ATTRIBUTE9     := p_counter_relationships_tbl(i).ATTRIBUTE9;
             l_counter_relationships_rec.ATTRIBUTE10    := p_counter_relationships_tbl(i).ATTRIBUTE10;
             l_counter_relationships_rec.ATTRIBUTE11    := p_counter_relationships_tbl(i).ATTRIBUTE11;
             l_counter_relationships_rec.ATTRIBUTE12    := p_counter_relationships_tbl(i).ATTRIBUTE12;
             l_counter_relationships_rec.ATTRIBUTE13    := p_counter_relationships_tbl(i).ATTRIBUTE13;
             l_counter_relationships_rec.ATTRIBUTE14    := p_counter_relationships_tbl(i).ATTRIBUTE14;
             l_counter_relationships_rec.ATTRIBUTE15    := p_counter_relationships_tbl(i).ATTRIBUTE15;
             l_counter_relationships_rec.ATTRIBUTE_CATEGORY  := p_counter_relationships_tbl(i).ATTRIBUTE_CATEGORY;


             CSI_COUNTER_TEMPLATE_PVT.create_counter_relationship
           	 (
           	   p_api_version	=>	1.0
           	  ,p_init_msg_list	=>	p_init_msg_list
           	  ,p_commit		=>	p_commit
           	  ,p_validation_level	=>	p_validation_level
                  ,p_counter_relationships_rec => l_counter_relationships_rec
           	  ,x_return_status	=>	x_return_status
           	  ,x_msg_count		=>	x_msg_count
           	  ,x_msg_data		=>	x_msg_data
           	 );
          	   IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                l_msg_index := 1;
                l_msg_count := x_msg_count;

                WHILE l_msg_count > 0 LOOP
                 x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                            FND_API.G_FALSE );
                 csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_TEMPLATE_PVT.CREATE_COUNTER_RELATIONSHIP API');
                 csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                 l_msg_index := l_msg_index + 1;
                 l_msg_count := l_msg_count - 1;
                END LOOP;
                RAISE FND_API.G_EXC_ERROR;
              END IF;
          END;
       END LOOP;
    END IF;

    IF p_ctr_derived_filters_tbl.count > 0 THEN
        FOR i in p_ctr_derived_filters_tbl.FIRST..p_ctr_derived_filters_tbl.LAST
         LOOP
            p_ctr_derived_filters_tbl(i).COUNTER_ID := l_counter_id;
         END LOOP;
    -- Insert derived filters
             CSI_COUNTER_TEMPLATE_PVT.create_derived_filters
           	 (
           	   p_api_version	=>	1.0
           	  ,p_init_msg_list	=>	p_init_msg_list
           	  ,p_commit		=>	p_commit
           	  ,p_validation_level	=>	p_validation_level
              ,p_ctr_derived_filters_tbl => p_ctr_derived_filters_tbl
           	  ,x_return_status	=>	x_return_status
           	  ,x_msg_count		=>	x_msg_count
           	  ,x_msg_data		=>	x_msg_data
           	 );
          	   IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                l_msg_index := 1;
                l_msg_count := x_msg_count;

                WHILE l_msg_count > 0 LOOP
                 x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                            FND_API.G_FALSE );
                 csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_TEMPLATE_PVT.CREATE_DERIVED_FILTERS API');
                 csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                 l_msg_index := l_msg_index + 1;
                 l_msg_count := l_msg_count - 1;
                END LOOP;
                RAISE FND_API.G_EXC_ERROR;
              END IF;
      END IF;

    -- Insert Counter associations
    IF p_counter_associations_tbl.count > 0 THEN
       FOR i in p_counter_associations_tbl.FIRST..p_counter_associations_tbl.LAST
       LOOP
          DECLARE
             l_instance_association_id NUMBER;
          BEGIN
             l_counter_associations_rec.COUNTER_ID  := l_counter_id;
             l_counter_associations_rec.SOURCE_OBJECT_CODE := p_counter_associations_tbl(i).SOURCE_OBJECT_CODE;
             l_counter_associations_rec.SOURCE_OBJECT_ID := p_counter_associations_tbl(i).SOURCE_OBJECT_ID;
             l_counter_associations_rec.START_DATE_ACTIVE  := p_counter_associations_tbl(i).START_DATE_ACTIVE ;
             l_counter_associations_rec.END_DATE_ACTIVE  := p_counter_associations_tbl(i).END_DATE_ACTIVE;
             l_counter_associations_rec.ATTRIBUTE1     := p_counter_associations_tbl(i).ATTRIBUTE1;
             l_counter_associations_rec.ATTRIBUTE2     := p_counter_associations_tbl(i).ATTRIBUTE2;
             l_counter_associations_rec.ATTRIBUTE3     := p_counter_associations_tbl(i).ATTRIBUTE3;
             l_counter_associations_rec.ATTRIBUTE4     := p_counter_associations_tbl(i).ATTRIBUTE4;
             l_counter_associations_rec.ATTRIBUTE5     := p_counter_associations_tbl(i).ATTRIBUTE5;
             l_counter_associations_rec.ATTRIBUTE6     := p_counter_associations_tbl(i).ATTRIBUTE6;
             l_counter_associations_rec.ATTRIBUTE7     := p_counter_associations_tbl(i).ATTRIBUTE7;
             l_counter_associations_rec.ATTRIBUTE8     := p_counter_associations_tbl(i).ATTRIBUTE8;
             l_counter_associations_rec.ATTRIBUTE9     := p_counter_associations_tbl(i).ATTRIBUTE9;
             l_counter_associations_rec.ATTRIBUTE10    := p_counter_associations_tbl(i).ATTRIBUTE10;
             l_counter_associations_rec.ATTRIBUTE11    := p_counter_associations_tbl(i).ATTRIBUTE11;
             l_counter_associations_rec.ATTRIBUTE12    := p_counter_associations_tbl(i).ATTRIBUTE12;
             l_counter_associations_rec.ATTRIBUTE13    := p_counter_associations_tbl(i).ATTRIBUTE13;
             l_counter_associations_rec.ATTRIBUTE14    := p_counter_associations_tbl(i).ATTRIBUTE14;
             l_counter_associations_rec.ATTRIBUTE15    := p_counter_associations_tbl(i).ATTRIBUTE15;
             l_counter_associations_rec.ATTRIBUTE_CATEGORY  := p_counter_associations_tbl(i).ATTRIBUTE_CATEGORY;
             l_counter_associations_rec.maint_organization_id := p_counter_associations_tbl(i).maint_organization_id;
             l_counter_associations_rec.primary_failure_flag := p_counter_associations_tbl(i).primary_failure_flag;

             -- Added to insert initial reading.
             l_src_obj_cd := p_counter_associations_tbl(i).SOURCE_OBJECT_CODE;
             l_src_obj_id := p_counter_associations_tbl(i).SOURCE_OBJECT_ID;


             CSI_COUNTER_PVT.create_ctr_associations
           	 (
           	   p_api_version	=>	1.0
           	  ,p_init_msg_list	=>	p_init_msg_list
           	  ,p_commit		=>	p_commit
           	  ,p_validation_level	=>	p_validation_level
                  ,p_counter_associations_rec => l_counter_associations_rec
           	  ,x_return_status	=>	x_return_status
           	  ,x_msg_count		=>	x_msg_count
           	  ,x_msg_data		=>	x_msg_data
           	  ,x_instance_association_id	=>	l_instance_association_id
           	 );
             IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                l_msg_index := 1;
                l_msg_count := x_msg_count;

                WHILE l_msg_count > 0 LOOP
                 x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                            FND_API.G_FALSE );
                 csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_PVT.CREATE_CTR_ASSOCIATIONS API');
                 csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                 l_msg_index := l_msg_index + 1;
                 l_msg_count := l_msg_count - 1;
                END LOOP;
                RAISE FND_API.G_EXC_ERROR;
             END IF;
          END;
       END LOOP;
    END IF;

    -- Insert initial reading by calling counter reading api.
    IF p_counter_instance_rec.counter_type = 'REGULAR' and  (p_counter_instance_rec.initial_reading is not null and
     p_counter_instance_rec.initial_reading <> FND_API.G_MISS_NUM) and nvl(l_counter_relationships_rec.RELATIONSHIP_TYPE_CODE,'X') <> l_rel_type then

      --create transaction record
      l_transaction_tbl(l_c_ind_txn)                                := NULL;
      l_transaction_tbl(l_c_ind_txn).TRANSACTION_ID                 := NULL;
      l_transaction_tbl(l_c_ind_txn).TRANSACTION_DATE               := sysdate;
      l_transaction_tbl(l_c_ind_txn).SOURCE_TRANSACTION_DATE        := sysdate;
      if l_src_obj_cd = 'CP' then
        l_transaction_type_id := 80;
      elsif l_src_obj_cd = 'CONTRACT_LINE' then
        l_transaction_type_id := 81;
      end if;
      if l_transaction_type_id is null then
        l_transaction_type_id := 80;
      end if;
      l_transaction_tbl(l_c_ind_txn).TRANSACTION_TYPE_ID            := l_transaction_type_id;
      l_transaction_tbl(l_c_ind_txn).TXN_SUB_TYPE_ID                := NULL;
      l_transaction_tbl(l_c_ind_txn).SOURCE_GROUP_REF_ID            := NULL;
      l_transaction_tbl(l_c_ind_txn).SOURCE_GROUP_REF               := NULL;
      l_transaction_tbl(l_c_ind_txn).SOURCE_HEADER_REF_ID           := l_src_obj_id;

      -- create counter readings table
      l_counter_readings_tbl(l_c_ind_rdg).COUNTER_VALUE_ID         :=  NULL;
      l_counter_readings_tbl(l_c_ind_rdg).COUNTER_ID               :=  l_counter_id;
      -- l_counter_readings_tbl(l_c_ind_rdg).VALUE_TIMESTAMP          :=  sysdate;
      l_counter_readings_tbl(l_c_ind_rdg).VALUE_TIMESTAMP          :=  p_counter_instance_rec.initial_reading_date;
      l_counter_readings_tbl(l_c_ind_rdg).COUNTER_READING          :=  p_counter_instance_rec.initial_reading;
      l_counter_readings_tbl(l_c_ind_rdg).initial_reading_flag     := 'Y';
      l_counter_readings_tbl(l_c_ind_rdg).DISABLED_FLAG            :=  'N';
      l_counter_readings_tbl(l_c_ind_rdg).comments                 :=  'Initial Reading';
      l_counter_readings_tbl(l_c_ind_rdg).PARENT_TBL_INDEX         :=  l_c_ind_txn;

      FOR dflt_rec IN DFLT_PROP_RDG(l_counter_id)
        LOOP
         l_ctr_property_readings_tbl(l_c_ind_prop).COUNTER_PROP_VALUE_ID := NULL;
         l_ctr_property_readings_tbl(l_c_ind_prop).COUNTER_PROPERTY_ID   := dflt_rec.counter_property_id;
         if dflt_rec.default_value is not null then
           l_ctr_property_readings_tbl(l_c_ind_prop).PROPERTY_VALUE := dflt_rec.default_value;
         else
           if dflt_rec.property_data_type = 'CHAR' then
             l_ctr_property_readings_tbl(l_c_ind_prop).PROPERTY_VALUE := 'Initial Reading';
           elsif dflt_rec.property_data_type = 'DATE' then
             l_ctr_property_readings_tbl(l_c_ind_prop).PROPERTY_VALUE := sysdate;
           else
             l_ctr_property_readings_tbl(l_c_ind_prop).PROPERTY_VALUE := '1';
           end if;
         end if;
         l_ctr_property_readings_tbl(l_c_ind_prop).VALUE_TIMESTAMP := sysdate;
         l_ctr_property_readings_tbl(l_c_ind_prop).PARENT_TBL_INDEX  := l_c_ind_rdg;
         l_c_ind_prop := l_c_ind_prop + 1;
        END LOOP;

     csi_counter_readings_pub.capture_counter_reading(
        p_api_version           => 1.0,
        p_commit                => p_commit,
        p_init_msg_list         => p_init_msg_list,
        p_validation_level      => p_validation_level,
        p_txn_tbl               => l_transaction_tbl,            --IN OUT NOCOPY csi_datastructures_pub.transaction_tbl
        p_ctr_rdg_tbl           => l_counter_readings_tbl,       --IN OUT NOCOPY csi_ctr_datastructures_pub.counter_readings_tbl
        p_ctr_prop_rdg_tbl      => l_ctr_property_readings_tbl,  --IN OUT NOCOPY csi_ctr_datastructures_pub.ctr_property_readings_tbl
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data
        );
    END IF;

    -- End of API body

   /* Customer post -processing  section - Mandatory  */
   IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'C' )  ) THEN
     CSI_COUNTER_CUHK.create_counter_post
     (
      p_api_version	                => p_api_version
      ,p_init_msg_list	             => p_init_msg_list
      ,p_commit		                   => p_commit
      ,p_validation_level           => p_validation_level
      ,p_counter_instance_rec	      => p_counter_instance_rec
      ,P_ctr_properties_tbl         => P_ctr_properties_tbl
      ,P_counter_relationships_tbl  => P_counter_relationships_tbl
      ,P_ctr_derived_filters_tbl    => P_ctr_derived_filters_tbl
      ,P_counter_associations_tbl   => P_counter_associations_tbl
      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
      ,x_ctr_id		                   => x_ctr_id
     );
     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;

         WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                           FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_CUHK.CREATE_COUNTER_POST API');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;
   /* Vertical post -processing  section - Mandatory  */
   IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'V' )  ) THEN
     CSI_COUNTER_VUHK.create_counter_post
     (
      p_api_version	                => p_api_version
      ,p_init_msg_list	             => p_init_msg_list
      ,p_commit		                   => p_commit
      ,p_validation_level           => p_validation_level
      ,p_counter_instance_rec	      => p_counter_instance_rec
      ,P_ctr_properties_tbl         => P_ctr_properties_tbl
      ,P_counter_relationships_tbl  => P_counter_relationships_tbl
      ,P_ctr_derived_filters_tbl    => P_ctr_derived_filters_tbl
      ,P_counter_associations_tbl   => P_counter_associations_tbl
      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
      ,x_ctr_id		                   => x_ctr_id
     );
     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;

         WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                           FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_VUHK.CREATE_COUNTER_POST API');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;

   -- Standard check of p_commit.
   IF FND_API.To_Boolean(nvl(p_commit,FND_API.G_FALSE)) THEN
      COMMIT WORK;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO create_counter_pub;
      FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count,
                 p_data  => x_msg_data
                );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_counter_pub;
      FND_MSG_PUB.Count_And_Get
      		(p_count => x_msg_count,
                 p_data  => x_msg_data
                );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_counter_pub;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
            (G_PKG_NAME,
             l_api_name
            );
       END IF;
       FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data
            );

END create_counter;

--|---------------------------------------------------
--| procedure name: create_ctr_property
--| description :   procedure used to
--|                 create counter properties
--|---------------------------------------------------

PROCEDURE create_ctr_property
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,P_ctr_properties_tbl        IN out NOCOPY CSI_CTR_DATASTRUCTURES_PUB.Ctr_properties_tbl
    ,x_return_status                OUT    NOCOPY VARCHAR2
    ,x_msg_count                    OUT    NOCOPY NUMBER
    ,x_msg_data                     OUT    NOCOPY VARCHAR2
    ,x_ctr_property_id	          OUT	NOCOPY NUMBER
 )
  IS
    l_api_name                      CONSTANT VARCHAR2(30)   := 'CREATE_CTR_PROPERTY';
    l_api_version                   CONSTANT NUMBER         := 1.0;
    -- l_debug_level                   NUMBER;
    l_flag                          VARCHAR2(1)             := 'N';
    l_msg_data                      VARCHAR2(2000);
    l_msg_index                     NUMBER;
    l_msg_count                     NUMBER;
    l_count                         NUMBER;
    l_return_message                VARCHAR2(100);

    l_Ctr_properties_rec            CSI_CTR_DATASTRUCTURES_PUB.Ctr_properties_rec;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  create_ctr_property_pub;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   -- Check the profile option debug_level for debug message reporting
   -- l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

   -- If debug_level = 1 then dump the procedure name
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'create_ctr_property');
   END IF;

   -- If the debug level = 2 then dump all the parameters values.
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 1) THEN
      csi_ctr_gen_utility_pvt.put_line( 'create_ctr_property'     ||
                                     p_api_version         ||'-'||
                                     p_commit              ||'-'||
                                     p_init_msg_list       ||'-'||
                                     p_validation_level );
      csi_ctr_gen_utility_pvt.dump_ctr_properties_tbl(p_ctr_properties_tbl);
   END IF;

   /* Customer pre -processing  section - Mandatory  */
   IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'C' )  ) THEN
     CSI_COUNTER_CUHK.create_ctr_property_pre
     (
      p_api_version	                => p_api_version
      ,p_init_msg_list	             => p_init_msg_list
      ,p_commit		                   => p_commit
      ,p_validation_level           => p_validation_level
      ,P_ctr_properties_tbl 	       => P_ctr_properties_tbl
      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
      ,x_ctr_property_id	           => x_ctr_property_id
     );
     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;

         WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                           FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_CUHK.CREATE_CTR_PROPERTY_PRE API');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;
   /* Vertical pre -processing  section - Mandatory  */
   IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' )  ) THEN
     CSI_COUNTER_VUHK.create_ctr_property_pre
     (
      p_api_version	                => p_api_version
      ,p_init_msg_list	             => p_init_msg_list
      ,p_commit		                   => p_commit
      ,p_validation_level           => p_validation_level
      ,P_ctr_properties_tbl 	       => P_ctr_properties_tbl
      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
      ,x_ctr_property_id	           => x_ctr_property_id
     );
     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;

         WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                           FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_VUHK.CREATE_CTR_PROPERTY_PRE API');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
     END IF ;
   END IF;

   -- Start of API Body

   IF p_ctr_properties_tbl.count > 0 THEN
       FOR j in p_ctr_properties_tbl.FIRST..p_ctr_properties_tbl.LAST
       LOOP
          DECLARE
             l_ctr_property_id NUMBER;
          BEGIN
             l_Ctr_properties_rec.counter_id := p_ctr_properties_tbl(j).counter_id;
             l_Ctr_properties_rec.NAME := p_ctr_properties_tbl(j).name;
             l_Ctr_properties_rec.DESCRIPTION  := p_ctr_properties_tbl(j).DESCRIPTION;
             l_Ctr_properties_rec.PROPERTY_DATA_TYPE := p_ctr_properties_tbl(j).PROPERTY_DATA_TYPE;
             l_Ctr_properties_rec.IS_NULLABLE  := p_ctr_properties_tbl(j).IS_NULLABLE;
             l_Ctr_properties_rec.DEFAULT_VALUE  := p_ctr_properties_tbl(j).DEFAULT_VALUE;
             l_Ctr_properties_rec.MINIMUM_VALUE  := p_ctr_properties_tbl(j).MINIMUM_VALUE;
             l_Ctr_properties_rec.MAXIMUM_VALUE  := p_ctr_properties_tbl(j).MAXIMUM_VALUE;
             l_Ctr_properties_rec.UOM_CODE       := p_ctr_properties_tbl(j).UOM_CODE;
             l_Ctr_properties_rec.START_DATE_ACTIVE  := p_ctr_properties_tbl(j).START_DATE_ACTIVE;
             l_Ctr_properties_rec.END_DATE_ACTIVE    := p_ctr_properties_tbl(j).END_DATE_ACTIVE;
             l_Ctr_properties_rec.PROPERTY_LOV_TYPE  := p_ctr_properties_tbl(j).PROPERTY_LOV_TYPE;
             l_Ctr_properties_rec.ATTRIBUTE1     := p_ctr_properties_tbl(j).ATTRIBUTE1;
             l_Ctr_properties_rec.ATTRIBUTE2     := p_ctr_properties_tbl(j).ATTRIBUTE2;
             l_Ctr_properties_rec.ATTRIBUTE3     := p_ctr_properties_tbl(j).ATTRIBUTE3;
             l_Ctr_properties_rec.ATTRIBUTE4     := p_ctr_properties_tbl(j).ATTRIBUTE4;
             l_Ctr_properties_rec.ATTRIBUTE5     := p_ctr_properties_tbl(j).ATTRIBUTE5;
             l_Ctr_properties_rec.ATTRIBUTE6     := p_ctr_properties_tbl(j).ATTRIBUTE6;
             l_Ctr_properties_rec.ATTRIBUTE7     := p_ctr_properties_tbl(j).ATTRIBUTE7;
             l_Ctr_properties_rec.ATTRIBUTE8     := p_ctr_properties_tbl(j).ATTRIBUTE8;
             l_Ctr_properties_rec.ATTRIBUTE9     := p_ctr_properties_tbl(j).ATTRIBUTE9;
             l_Ctr_properties_rec.ATTRIBUTE10    := p_ctr_properties_tbl(j).ATTRIBUTE10;
             l_Ctr_properties_rec.ATTRIBUTE11    := p_ctr_properties_tbl(j).ATTRIBUTE11;
             l_Ctr_properties_rec.ATTRIBUTE12    := p_ctr_properties_tbl(j).ATTRIBUTE12;
             l_Ctr_properties_rec.ATTRIBUTE13    := p_ctr_properties_tbl(j).ATTRIBUTE13;
             l_Ctr_properties_rec.ATTRIBUTE14    := p_ctr_properties_tbl(j).ATTRIBUTE14;
             l_Ctr_properties_rec.ATTRIBUTE15    := p_ctr_properties_tbl(j).ATTRIBUTE15;
             l_Ctr_properties_rec.ATTRIBUTE_CATEGORY  := p_ctr_properties_tbl(j).ATTRIBUTE_CATEGORY;


             CSI_COUNTER_PVT.create_ctr_property
           	 (
           	   p_api_version	=>	1.0
           	  ,p_init_msg_list	=>	p_init_msg_list
           	  ,p_commit		=>	p_commit
           	  ,p_validation_level	=>	p_validation_level
                  ,p_ctr_properties_rec =>      l_Ctr_properties_rec
           	  ,x_return_status	=>	x_return_status
           	  ,x_msg_count		=>	x_msg_count
           	  ,x_msg_data		=>	x_msg_data
           	  ,x_ctr_property_id    =>	l_ctr_property_id
           	  );
              IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                l_msg_index := 1;
                l_msg_count := x_msg_count;

                WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                           FND_API.G_FALSE );
                  csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_PVT.CREATE_CTR_PROPERTY API');
                  csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                  l_msg_index := l_msg_index + 1;
                  l_msg_count := l_msg_count - 1;
               END LOOP;
               RAISE FND_API.G_EXC_ERROR;
             END IF;
          END;
       END LOOP;
    END IF;

    -- End of API body

   /* Customer post -processing  section - Mandatory  */
   IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'C' )  ) THEN
     CSI_COUNTER_CUHK.create_ctr_property_post
     (
      p_api_version	                => p_api_version
      ,p_init_msg_list	             => p_init_msg_list
      ,p_commit		                   => p_commit
      ,p_validation_level           => p_validation_level
      ,P_ctr_properties_tbl 	       => P_ctr_properties_tbl
      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
      ,x_ctr_property_id	           => x_ctr_property_id
     );
     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;

         WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                           FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_CUHK.CREATE_CTR_PROPERTY_POST API');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;
   /* Vertical post -processing  section - Mandatory  */
   IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'V' )  ) THEN
     CSI_COUNTER_VUHK.create_ctr_property_post
     (
      p_api_version	                => p_api_version
      ,p_init_msg_list	             => p_init_msg_list
      ,p_commit		                   => p_commit
      ,p_validation_level           => p_validation_level
      ,P_ctr_properties_tbl 	       => P_ctr_properties_tbl
      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
      ,x_ctr_property_id	           => x_ctr_property_id
     );
     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;

         WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                           FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_CUHK.CREATE_CTR_PROPERTY_POST API');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean(nvl(p_commit,FND_API.G_FALSE)) THEN
       COMMIT WORK;
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO create_ctr_property_pub;
      FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count,
                 p_data  => x_msg_data
                );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_ctr_property_pub;
      FND_MSG_PUB.Count_And_Get
      		(p_count => x_msg_count,
                 p_data  => x_msg_data
                );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_ctr_property_pub;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
            (G_PKG_NAME,
             l_api_name
            );
       END IF;
       FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data
            );

END create_ctr_property;

--|---------------------------------------------------
--| procedure name: create_ctr_associations
--| description :   procedure used to
--|                 create counter associations
--|---------------------------------------------------

PROCEDURE create_ctr_associations
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,P_counter_associations_tbl IN out NOCOPY CSI_CTR_DATASTRUCTURES_PUB.counter_associations_tbl
    ,x_return_status                OUT    NOCOPY VARCHAR2
    ,x_msg_count                    OUT    NOCOPY NUMBER
    ,x_msg_data                     OUT    NOCOPY VARCHAR2
    ,x_instance_association_id      OUT	NOCOPY NUMBER
 )
 IS
    l_api_name                      CONSTANT VARCHAR2(30)   := 'CREATE_CTR_ASSOCIATIONS';
    l_api_version                   CONSTANT NUMBER         := 1.0;
    -- l_debug_level                   NUMBER;
    l_flag                          VARCHAR2(1)             := 'N';
    l_msg_data                      VARCHAR2(2000);
    l_msg_index                     NUMBER;
    l_msg_count                     NUMBER;
    l_count                         NUMBER;
    l_return_message                VARCHAR2(100);

    l_counter_associations_rec      CSI_CTR_DATASTRUCTURES_PUB.counter_associations_rec;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  create_ctr_associations_pub;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   -- Check the profile option debug_level for debug message reporting
   -- l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

   -- If debug_level = 1 then dump the procedure name
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'create_ctr_associations');
   END IF;

   -- If the debug level = 2 then dump all the parameters values.
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 1) THEN
      csi_ctr_gen_utility_pvt.put_line( 'create_ctr_associations'     ||
                                     p_api_version         ||'-'||
                                     p_commit              ||'-'||
                                     p_init_msg_list       ||'-'||
                                     p_validation_level );
      csi_ctr_gen_utility_pvt.dump_counter_associations_tbl(p_counter_associations_tbl);
   END IF;

   /* Customer pre -processing  section - Mandatory  */
   IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'C' )  ) THEN
     CSI_COUNTER_CUHK.create_ctr_associations_pre
     (
      p_api_version	                => p_api_version
      ,p_init_msg_list	             => p_init_msg_list
      ,p_commit		                   => p_commit
      ,p_validation_level           => p_validation_level
      ,P_counter_associations_tbl 	 => P_counter_associations_tbl
      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
      ,x_instance_association_id    => x_instance_association_id
     );
     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;

         WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                           FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_CUHK.CREATE_CTR_ASSOCIATIONS_PRE API');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;

   /* Vertical pre -processing  section - Mandatory  */
   IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' )  ) THEN
     CSI_COUNTER_VUHK.create_ctr_associations_pre
     (
      p_api_version	                => p_api_version
      ,p_init_msg_list	             => p_init_msg_list
      ,p_commit		                   => p_commit
      ,p_validation_level           => p_validation_level
      ,P_counter_associations_tbl   => P_counter_associations_tbl
      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
      ,x_instance_association_id	   => x_instance_association_id
     );
     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;

         WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                           FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_VUHK.CREATE_CTR_ASSOCIATIONS_PRE API');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;

   -- Start of API Body

   IF p_counter_associations_tbl.count > 0 THEN
       FOR i in p_counter_associations_tbl.FIRST..p_counter_associations_tbl.LAST
       LOOP
          DECLARE
             l_instance_association_id NUMBER;
          BEGIN
             l_counter_associations_rec.COUNTER_ID  := p_counter_associations_tbl(i).counter_id;
             l_counter_associations_rec.SOURCE_OBJECT_CODE := p_counter_associations_tbl(i).SOURCE_OBJECT_CODE;
             l_counter_associations_rec.SOURCE_OBJECT_ID := p_counter_associations_tbl(i).SOURCE_OBJECT_ID;
             l_counter_associations_rec.START_DATE_ACTIVE  := p_counter_associations_tbl(i).START_DATE_ACTIVE ;
             l_counter_associations_rec.END_DATE_ACTIVE  := p_counter_associations_tbl(i).END_DATE_ACTIVE;
             l_counter_associations_rec.ATTRIBUTE1     := p_counter_associations_tbl(i).ATTRIBUTE1;
             l_counter_associations_rec.ATTRIBUTE2     := p_counter_associations_tbl(i).ATTRIBUTE2;
             l_counter_associations_rec.ATTRIBUTE3     := p_counter_associations_tbl(i).ATTRIBUTE3;
             l_counter_associations_rec.ATTRIBUTE4     := p_counter_associations_tbl(i).ATTRIBUTE4;
             l_counter_associations_rec.ATTRIBUTE5     := p_counter_associations_tbl(i).ATTRIBUTE5;
             l_counter_associations_rec.ATTRIBUTE6     := p_counter_associations_tbl(i).ATTRIBUTE6;
             l_counter_associations_rec.ATTRIBUTE7     := p_counter_associations_tbl(i).ATTRIBUTE7;
             l_counter_associations_rec.ATTRIBUTE8     := p_counter_associations_tbl(i).ATTRIBUTE8;
             l_counter_associations_rec.ATTRIBUTE9     := p_counter_associations_tbl(i).ATTRIBUTE9;
             l_counter_associations_rec.ATTRIBUTE10    := p_counter_associations_tbl(i).ATTRIBUTE10;
             l_counter_associations_rec.ATTRIBUTE11    := p_counter_associations_tbl(i).ATTRIBUTE11;
             l_counter_associations_rec.ATTRIBUTE12    := p_counter_associations_tbl(i).ATTRIBUTE12;
             l_counter_associations_rec.ATTRIBUTE13    := p_counter_associations_tbl(i).ATTRIBUTE13;
             l_counter_associations_rec.ATTRIBUTE14    := p_counter_associations_tbl(i).ATTRIBUTE14;
             l_counter_associations_rec.ATTRIBUTE15    := p_counter_associations_tbl(i).ATTRIBUTE15;
             l_counter_associations_rec.ATTRIBUTE_CATEGORY  := p_counter_associations_tbl(i).ATTRIBUTE_CATEGORY;
             l_counter_associations_rec.maint_organization_id := p_counter_associations_tbl(i).maint_organization_id;
             l_counter_associations_rec.primary_failure_flag := p_counter_associations_tbl(i).primary_failure_flag;

             CSI_COUNTER_PVT.create_ctr_associations
           	 (
           	   p_api_version	=>	1.0
           	  ,p_init_msg_list	=>	p_init_msg_list
           	  ,p_commit		=>	p_commit
           	  ,p_validation_level	=>	p_validation_level
                  ,p_counter_associations_rec => l_counter_associations_rec
           	  ,x_return_status	=>	x_return_status
           	  ,x_msg_count		=>	x_msg_count
           	  ,x_msg_data		=>	x_msg_data
           	  ,x_instance_association_id	=>	l_instance_association_id
           	 );
             IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
               l_msg_index := 1;
               l_msg_count := x_msg_count;

               WHILE l_msg_count > 0 LOOP
                 x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                           FND_API.G_FALSE );
                 csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_PVT.CREATE_CTR_ASSOCIATIONS API');
                 csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                 l_msg_index := l_msg_index + 1;
                 l_msg_count := l_msg_count - 1;
               END LOOP;
               RAISE FND_API.G_EXC_ERROR;
             END IF;
          END;
       END LOOP;
    END IF;

   /* Customer post -processing  section - Mandatory  */
   IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'C' )  ) THEN
     CSI_COUNTER_CUHK.create_ctr_associations_post
     (
      p_api_version	                => p_api_version
      ,p_init_msg_list	             => p_init_msg_list
      ,p_commit		                   => p_commit
      ,p_validation_level           => p_validation_level
      ,P_counter_associations_tbl 	 => P_counter_associations_tbl
      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
      ,x_instance_association_id    => x_instance_association_id
     );
     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;

         WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                           FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_CUHK.CREATE_CTR_ASSOCIATIONS_POST API');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;

   /* Vertical post -processing  section - Mandatory  */
   IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'V' )  ) THEN
     CSI_COUNTER_VUHK.create_ctr_associations_post
     (
      p_api_version	                => p_api_version
      ,p_init_msg_list	             => p_init_msg_list
      ,p_commit		                   => p_commit
      ,p_validation_level           => p_validation_level
      ,P_counter_associations_tbl   => P_counter_associations_tbl
      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
      ,x_instance_association_id	   => x_instance_association_id
     );
     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;

         WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                           FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_VUHK.CREATE_CTR_ASSOCIATIONS_POST API');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;

    -- End of API body

    -- Standard check of p_commit.
    IF FND_API.To_Boolean(nvl(p_commit,FND_API.G_FALSE)) THEN
       COMMIT WORK;
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO create_ctr_associations_pub;
      FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count,
                 p_data  => x_msg_data
                );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_ctr_associations_pub;
      FND_MSG_PUB.Count_And_Get
      		(p_count => x_msg_count,
                 p_data  => x_msg_data
                );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_ctr_associations_pub;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
            (G_PKG_NAME,
             l_api_name
            );
       END IF;
       FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data
            );

END create_ctr_associations;

--|---------------------------------------------------
--| procedure name: create_reading_lock
--| description :   procedure used to
--|                 create reading lock on a counter
--|---------------------------------------------------

PROCEDURE create_reading_lock
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_ctr_reading_lock_rec IN OUT    NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_reading_lock_rec
    ,x_return_status           OUT    NOCOPY VARCHAR2
    ,x_msg_count               OUT    NOCOPY NUMBER
    ,x_msg_data                OUT    NOCOPY VARCHAR2
    ,x_reading_lock_id         OUT   	NOCOPY NUMBER
 )
 IS
    l_api_name                      CONSTANT VARCHAR2(30)   := 'CREATE_READING_LOCK';
    l_api_version                   CONSTANT NUMBER         := 1.0;
    -- l_debug_level                   NUMBER;
    l_flag                          VARCHAR2(1)             := 'N';
    l_msg_data                      VARCHAR2(2000);
    l_msg_index                     NUMBER;
    l_msg_count                     NUMBER;
    l_count                         NUMBER;
    l_return_message                VARCHAR2(100);

    l_reading_lock_id               NUMBER;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  create_reading_lock_pub;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   -- Check the profile option debug_level for debug message reporting
   -- l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

   -- If debug_level = 1 then dump the procedure name
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'create_reading_lock');
   END IF;

   -- If the debug level = 2 then dump all the parameters values.
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 1) THEN
      csi_ctr_gen_utility_pvt.put_line( 'create_reading_lock'     ||
                                     p_api_version         ||'-'||
                                     p_commit              ||'-'||
                                     p_init_msg_list       ||'-'||
                                     p_validation_level );
      csi_ctr_gen_utility_pvt.dump_ctr_reading_lock_rec(p_ctr_reading_lock_rec);
   END IF;

   /* Customer pre -processing  section - Mandatory  */
   IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'C' )  ) THEN
     CSI_COUNTER_CUHK.create_reading_lock_pre
     (
      p_api_version	                => p_api_version
      ,p_init_msg_list	            => p_init_msg_list
      ,p_commit		                => p_commit
      ,p_validation_level           => p_validation_level
      ,p_ctr_reading_lock_rec	    => p_ctr_reading_lock_rec
      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
      ,x_reading_lock_id            => x_reading_lock_id
     );
     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;

         WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                           FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_CUHK.CREATE_READING_LOCK_PRE API');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;
   /* Vertical pre -processing  section - Mandatory  */
   IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' )  ) THEN
     CSI_COUNTER_VUHK.create_reading_lock_pre
     (
      p_api_version	                => p_api_version
      ,p_init_msg_list	            => p_init_msg_list
      ,p_commit		                => p_commit
      ,p_validation_level           => p_validation_level
      ,p_ctr_reading_lock_rec	    => p_ctr_reading_lock_rec
      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
      ,x_reading_lock_id            => x_reading_lock_id
     );
     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;

         WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                           FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_VUHK.CREATE_READING_LOCK_PRE API');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;

   -- Start of API Body

   CSI_COUNTER_PVT.create_reading_lock
   (
     p_api_version	=>	1.0
    ,p_init_msg_list	=>	p_init_msg_list
    ,p_commit		=>	p_commit
    ,p_validation_level	=>	p_validation_level
    ,p_ctr_reading_lock_rec => p_ctr_reading_lock_rec
    ,x_return_status	=>	x_return_status
    ,x_msg_count	=>	x_msg_count
    ,x_msg_data		=>	x_msg_data
    ,x_reading_lock_id  =>	l_reading_lock_id
    );
    IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;

         WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                           FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_PVT.CREATE_READING_LOCK API');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
     END IF;

   -- End of API body

   /* Customer post -processing  section - Mandatory  */
   IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'C' )  ) THEN
     CSI_COUNTER_CUHK.create_reading_lock_post
     (
      p_api_version	                => p_api_version
      ,p_init_msg_list	            => p_init_msg_list
      ,p_commit		                => p_commit
      ,p_validation_level           => p_validation_level
      ,p_ctr_reading_lock_rec	    => p_ctr_reading_lock_rec
      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
      ,x_reading_lock_id            => x_reading_lock_id
     );
     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;

         WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                           FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_CUHK.CREATE_READING_LOCK_POST API');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;
   /* Vertical post -processing  section - Mandatory  */
   IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'V' )  ) THEN
     CSI_COUNTER_VUHK.create_reading_lock_post
     (
      p_api_version	                => p_api_version
      ,p_init_msg_list	            => p_init_msg_list
      ,p_commit		                => p_commit
      ,p_validation_level           => p_validation_level
      ,p_ctr_reading_lock_rec	    => p_ctr_reading_lock_rec
      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
      ,x_reading_lock_id            => x_reading_lock_id
     );
     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;

         WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                           FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_VUHK.CREATE_READING_LOCK_POST API');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;



    -- Standard check of p_commit.
    IF FND_API.To_Boolean(nvl(p_commit,FND_API.G_FALSE)) THEN
       COMMIT WORK;
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO create_reading_lock_pub;
      FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count,
                 p_data  => x_msg_data
                );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_reading_lock_pub;
      FND_MSG_PUB.Count_And_Get
      		(p_count => x_msg_count,
                 p_data  => x_msg_data
                );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_reading_lock_pub;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
            (G_PKG_NAME,
             l_api_name
            );
       END IF;
       FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data
            );

END create_reading_lock;

--|---------------------------------------------------
--| procedure name: create_daily_usage
--| description :   procedure used to
--|                 create daily usage
--|---------------------------------------------------

PROCEDURE create_daily_usage
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_ctr_usage_forecast_rec    IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_usage_forecast_rec
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,x_instance_forecast_id         OUT	NOCOPY NUMBER
 )
 IS
    l_api_name                      CONSTANT VARCHAR2(30)   := 'CREATE_DAILY_USAGE';
    l_api_version                   CONSTANT NUMBER         := 1.0;
    -- l_debug_level                   NUMBER;
    l_flag                          VARCHAR2(1)             := 'N';
    l_msg_data                      VARCHAR2(2000);
    l_msg_index                     NUMBER;
    l_msg_count                     NUMBER;
    l_count                         NUMBER;
    l_return_message                VARCHAR2(100);

    l_instance_forecast_id          NUMBER;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  create_daily_usage_pub;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   -- Check the profile option debug_level for debug message reporting
   -- l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

   -- If debug_level = 1 then dump the procedure name
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'create_daily_usage');
   END IF;

   -- If the debug level = 2 then dump all the parameters values.
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 1) THEN
      csi_ctr_gen_utility_pvt.put_line( 'create_daily_usage'     ||
                                     p_api_version         ||'-'||
                                     p_commit              ||'-'||
                                     p_init_msg_list       ||'-'||
                                     p_validation_level );
      csi_ctr_gen_utility_pvt.dump_ctr_usage_forecast_rec(p_ctr_usage_forecast_rec);
   END IF;

   /* Customer pre -processing  section - Mandatory  */
   IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'C' )  ) THEN
     CSI_COUNTER_CUHK.create_daily_usage_pre
     (
      p_api_version	                => p_api_version
      ,p_init_msg_list	            => p_init_msg_list
      ,p_commit		                => p_commit
      ,p_validation_level           => p_validation_level
      ,p_ctr_usage_forecast_rec	    => p_ctr_usage_forecast_rec
      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
      ,x_instance_forecast_id       => x_instance_forecast_id
     );
     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;

         WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                           FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_CUHK.CREATE_DAILY_USAGE_PRE API');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;
   /* Vertical pre -processing  section - Mandatory  */
   IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' )  ) THEN
     CSI_COUNTER_VUHK.create_daily_usage_pre
     (
      p_api_version	                => p_api_version
      ,p_init_msg_list	            => p_init_msg_list
      ,p_commit		                => p_commit
      ,p_validation_level           => p_validation_level
      ,p_ctr_usage_forecast_rec	    => p_ctr_usage_forecast_rec
      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
      ,x_instance_forecast_id       => x_instance_forecast_id
     );
     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;

         WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                           FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_VUHK.CREATE_DAILY_USAGE_PRE API');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;

   -- Start of API Body

   CSI_COUNTER_PVT.create_daily_usage
   (
     p_api_version	=>	1.0
    ,p_init_msg_list	=>	p_init_msg_list
    ,p_commit		=>	p_commit
    ,p_validation_level	=>	p_validation_level
    ,p_ctr_usage_forecast_rec => p_ctr_usage_forecast_rec
    ,x_return_status	=>	x_return_status
    ,x_msg_count	=>	x_msg_count
    ,x_msg_data		=>	x_msg_data
    ,x_instance_forecast_id =>	l_instance_forecast_id
    );
    IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;

         WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                           FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_PVT.CREATE_DAILY_USAGE API');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
     END IF;

    -- End of API body

    /* Customer post -processing  section - Mandatory  */
   IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'C' )  ) THEN
     CSI_COUNTER_CUHK.create_daily_usage_post
     (
      p_api_version	            => p_api_version
      ,p_init_msg_list	            => p_init_msg_list
      ,p_commit		            => p_commit
      ,p_validation_level           => p_validation_level
      ,p_ctr_usage_forecast_rec	    => p_ctr_usage_forecast_rec
      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
      ,x_instance_forecast_id       => x_instance_forecast_id
     );
     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;

         WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                           FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_CUHK.CREATE_DAILY_USAGE_POST API');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;
   /* Vertical post -processing  section - Mandatory  */
   IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'V' )  ) THEN
     CSI_COUNTER_VUHK.create_daily_usage_post
     (
      p_api_version	                => p_api_version
      ,p_init_msg_list	            => p_init_msg_list
      ,p_commit		                => p_commit
      ,p_validation_level           => p_validation_level
      ,p_ctr_usage_forecast_rec	    => p_ctr_usage_forecast_rec
      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
      ,x_instance_forecast_id       => x_instance_forecast_id
     );
     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;

         WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                           FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_VUHK.CREATE_DAILY_USAGE_POST API');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean(nvl(p_commit,FND_API.G_FALSE)) THEN
       COMMIT WORK;
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO create_daily_usage_pub;
      FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count,
                 p_data  => x_msg_data
                );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_daily_usage_pub;
      FND_MSG_PUB.Count_And_Get
      		(p_count => x_msg_count,
                 p_data  => x_msg_data
                );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO create_daily_usage_pub;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
            (G_PKG_NAME,
             l_api_name
            );
       END IF;
       FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data
            );

END create_daily_usage;

--|---------------------------------------------------
--| procedure name: update_counter
--| description :   procedure used to
--|                 update counter
--|---------------------------------------------------

PROCEDURE update_counter
 (
     p_api_version	             IN	NUMBER
    ,p_init_msg_list	          	IN	VARCHAR2
    ,p_commit		                 IN	VARCHAR2
    ,p_validation_level         IN NUMBER
    ,p_counter_instance_rec	    IN out	NOCOPY CSI_CTR_DATASTRUCTURES_PUB.Counter_instance_rec
    ,P_ctr_properties_tbl       IN out NOCOPY CSI_CTR_DATASTRUCTURES_PUB.Ctr_properties_tbl
    ,P_counter_relationships_tbl IN out NOCOPY CSI_CTR_DATASTRUCTURES_PUB.counter_relationships_tbl
    ,P_ctr_derived_filters_tbl  IN out NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_derived_filters_tbl
    ,P_counter_associations_tbl IN out NOCOPY CSI_CTR_DATASTRUCTURES_PUB.counter_associations_tbl
    ,x_return_status               out NOCOPY VARCHAR2
    ,x_msg_count                   out NOCOPY NUMBER
    ,x_msg_data                    out NOCOPY VARCHAR2
 )
 IS
    l_api_name                      CONSTANT VARCHAR2(30)   := 'UPDATE_COUNTER';
    l_api_version                   CONSTANT NUMBER         := 1.0;
    -- l_debug_level                   NUMBER;
    l_flag                          VARCHAR2(1)             := 'N';
    l_msg_data                      VARCHAR2(2000);
    l_msg_index                     NUMBER;
    l_msg_count                     NUMBER;
    l_count                         NUMBER;
    l_return_message                VARCHAR2(100);

    l_Ctr_properties_rec            CSI_CTR_DATASTRUCTURES_PUB.Ctr_properties_rec;
    l_counter_relationships_rec     CSI_CTR_DATASTRUCTURES_PUB.counter_relationships_rec;
    l_ctr_derived_filters_rec       CSI_CTR_DATASTRUCTURES_PUB.ctr_derived_filters_rec;
    l_counter_associations_rec      CSI_CTR_DATASTRUCTURES_PUB.counter_associations_rec;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  update_counter_pub;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   -- Check the profile option debug_level for debug message reporting
   -- l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

   -- If debug_level = 1 then dump the procedure name
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'update_counter');
   END IF;

   -- If the debug level = 2 then dump all the parameters values.
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 1) THEN
      csi_ctr_gen_utility_pvt.put_line( 'update_counter'     ||
                                     p_api_version         ||'-'||
                                     p_commit              ||'-'||
                                     p_init_msg_list       ||'-'||
                                     p_validation_level );
      csi_ctr_gen_utility_pvt.dump_counter_instance_rec(p_counter_instance_rec);
   END IF;

   /* Customer pre -processing  section - Mandatory  */
   IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'C' )  ) THEN
     CSI_COUNTER_CUHK.update_counter_pre
     (
      p_api_version	                => p_api_version
      ,p_init_msg_list	             => p_init_msg_list
      ,p_commit		                   => p_commit
      ,p_validation_level           => p_validation_level
      ,p_counter_instance_rec	      => p_counter_instance_rec
      ,P_ctr_properties_tbl         => P_ctr_properties_tbl
      ,P_counter_relationships_tbl  => P_counter_relationships_tbl
      ,P_ctr_derived_filters_tbl    => P_ctr_derived_filters_tbl
      --,P_counter_associations_tbl   => P_counter_associations_tbl
      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
     );
     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;

         WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                           FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_CUHK.UPDATE_COUNTER_PRE API');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;
   /* Vertical pre -processing  section - Mandatory  */
   IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' )  ) THEN
     CSI_COUNTER_VUHK.update_counter_pre
     (
      p_api_version	                => p_api_version
      ,p_init_msg_list	             => p_init_msg_list
      ,p_commit		                   => p_commit
      ,p_validation_level           => p_validation_level
      ,p_counter_instance_rec	      => p_counter_instance_rec
      ,P_ctr_properties_tbl         => P_ctr_properties_tbl
      ,P_counter_relationships_tbl  => P_counter_relationships_tbl
      ,P_ctr_derived_filters_tbl    => P_ctr_derived_filters_tbl
      --,P_counter_associations_tbl   => P_counter_associations_tbl
      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
     );
     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;

         WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                           FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_VUHK.UPDATE_COUNTER_PRE API');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;

   -- Start of API Body
   CSI_COUNTER_PVT.update_counter
   (
     p_api_version	=>	1.0
    ,p_init_msg_list	=>	p_init_msg_list
    ,p_commit		=>	p_commit
    ,p_validation_level	=>	p_validation_level
    ,p_counter_instance_rec => p_counter_instance_rec
    ,x_return_status	=>	x_return_status
    ,x_msg_count	=>	x_msg_count
    ,x_msg_data		=>	x_msg_data
    );
    IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;

         WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                           FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_PVT.UPDATE_COUNTER API');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
     END IF;

    -- Update Counter Properties
    IF p_ctr_properties_tbl.count > 0 THEN
       FOR j in p_ctr_properties_tbl.FIRST..p_ctr_properties_tbl.LAST
       LOOP
          DECLARE
             l_ctr_property_id NUMBER;
          BEGIN
             l_Ctr_properties_rec.COUNTER_PROPERTY_ID := p_ctr_properties_tbl(j).COUNTER_PROPERTY_ID;
             l_Ctr_properties_rec.counter_id := p_ctr_properties_tbl(j).counter_id;
             l_Ctr_properties_rec.NAME := p_ctr_properties_tbl(j).name;
             l_Ctr_properties_rec.DESCRIPTION  := p_ctr_properties_tbl(j).DESCRIPTION;
             l_Ctr_properties_rec.PROPERTY_DATA_TYPE := p_ctr_properties_tbl(j).PROPERTY_DATA_TYPE;
             l_Ctr_properties_rec.IS_NULLABLE  := p_ctr_properties_tbl(j).IS_NULLABLE;
             l_Ctr_properties_rec.DEFAULT_VALUE  := p_ctr_properties_tbl(j).DEFAULT_VALUE;
             l_Ctr_properties_rec.MINIMUM_VALUE  := p_ctr_properties_tbl(j).MINIMUM_VALUE;
             l_Ctr_properties_rec.MAXIMUM_VALUE  := p_ctr_properties_tbl(j).MAXIMUM_VALUE;
             l_Ctr_properties_rec.UOM_CODE       := p_ctr_properties_tbl(j).UOM_CODE;
             l_Ctr_properties_rec.START_DATE_ACTIVE  := p_ctr_properties_tbl(j).START_DATE_ACTIVE;
             l_Ctr_properties_rec.END_DATE_ACTIVE    := p_ctr_properties_tbl(j).END_DATE_ACTIVE;
             l_Ctr_properties_rec.PROPERTY_LOV_TYPE  := p_ctr_properties_tbl(j).PROPERTY_LOV_TYPE;
             l_Ctr_properties_rec.OBJECT_VERSION_NUMBER := p_ctr_properties_tbl(j).OBJECT_VERSION_NUMBER;
             l_Ctr_properties_rec.ATTRIBUTE1     := p_ctr_properties_tbl(j).ATTRIBUTE1;
             l_Ctr_properties_rec.ATTRIBUTE2     := p_ctr_properties_tbl(j).ATTRIBUTE2;
             l_Ctr_properties_rec.ATTRIBUTE3     := p_ctr_properties_tbl(j).ATTRIBUTE3;
             l_Ctr_properties_rec.ATTRIBUTE4     := p_ctr_properties_tbl(j).ATTRIBUTE4;
             l_Ctr_properties_rec.ATTRIBUTE5     := p_ctr_properties_tbl(j).ATTRIBUTE5;
             l_Ctr_properties_rec.ATTRIBUTE6     := p_ctr_properties_tbl(j).ATTRIBUTE6;
             l_Ctr_properties_rec.ATTRIBUTE7     := p_ctr_properties_tbl(j).ATTRIBUTE7;
             l_Ctr_properties_rec.ATTRIBUTE8     := p_ctr_properties_tbl(j).ATTRIBUTE8;
             l_Ctr_properties_rec.ATTRIBUTE9     := p_ctr_properties_tbl(j).ATTRIBUTE9;
             l_Ctr_properties_rec.ATTRIBUTE10    := p_ctr_properties_tbl(j).ATTRIBUTE10;
             l_Ctr_properties_rec.ATTRIBUTE11    := p_ctr_properties_tbl(j).ATTRIBUTE11;
             l_Ctr_properties_rec.ATTRIBUTE12    := p_ctr_properties_tbl(j).ATTRIBUTE12;
             l_Ctr_properties_rec.ATTRIBUTE13    := p_ctr_properties_tbl(j).ATTRIBUTE13;
             l_Ctr_properties_rec.ATTRIBUTE14    := p_ctr_properties_tbl(j).ATTRIBUTE14;
             l_Ctr_properties_rec.ATTRIBUTE15    := p_ctr_properties_tbl(j).ATTRIBUTE15;
             l_Ctr_properties_rec.ATTRIBUTE_CATEGORY  := p_ctr_properties_tbl(j).ATTRIBUTE_CATEGORY;

             If l_Ctr_properties_rec.COUNTER_PROPERTY_ID = FND_API.G_MISS_NUM THEN
               l_Ctr_properties_rec.COUNTER_PROPERTY_ID :=  null;
             END IF;

             IF l_Ctr_properties_rec.COUNTER_PROPERTY_ID IS NOT NULL THEN
              CSI_COUNTER_PVT.update_ctr_property
            	 (
           	   p_api_version	=>	1.0
           	  ,p_init_msg_list	=>	p_init_msg_list
           	  ,p_commit		=>	p_commit
           	  ,p_validation_level	=>	p_validation_level
              ,p_ctr_properties_rec => l_ctr_properties_rec
           	  ,x_return_status	=>	x_return_status
           	  ,x_msg_count		=>	x_msg_count
           	  ,x_msg_data		=>	x_msg_data
           	  );
              IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                l_msg_index := 1;
                l_msg_count := x_msg_count;

                WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                           FND_API.G_FALSE );
                  csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_PVT.UPDATE_CTR_PROPERTY API');
                  csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                  l_msg_index := l_msg_index + 1;
                  l_msg_count := l_msg_count - 1;
                END LOOP;
                RAISE FND_API.G_EXC_ERROR;
              END IF;
             ELSE -- PROPERTY ID IS NULL. INSERT NEW PROPERTY
              l_Ctr_properties_rec.counter_id := p_counter_instance_rec.counter_id;
              CSI_COUNTER_PVT.create_ctr_property
           	  (
           	   p_api_version	=>	1.0
           	  ,p_init_msg_list	=>	p_init_msg_list
           	  ,p_commit		=>	p_commit
           	  ,p_validation_level	=>	p_validation_level
              ,p_ctr_properties_rec =>  l_Ctr_properties_rec
           	  ,x_return_status	=>	x_return_status
           	  ,x_msg_count	        =>	x_msg_count
           	  ,x_msg_data		=>	x_msg_data
           	  ,x_ctr_property_id	=>	l_ctr_property_id
           	  );
          	   IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                l_msg_index := 1;
                l_msg_count := x_msg_count;

                WHILE l_msg_count > 0 LOOP
                 x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                            FND_API.G_FALSE );
                 csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_PVT.CREATE_CTR_PROPERTY API');
                 csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                 l_msg_index := l_msg_index + 1;
                 l_msg_count := l_msg_count - 1;
                END LOOP;
                RAISE FND_API.G_EXC_ERROR;
              END IF;
             END IF;
          END;
       END LOOP;
    END IF;

    -- Update Counter relationships
    IF P_counter_relationships_tbl.count > 0 THEN
       FOR i in p_counter_relationships_tbl.FIRST..p_counter_relationships_tbl.LAST
       LOOP
          BEGIN
             l_counter_relationships_rec.RELATIONSHIP_ID := p_counter_relationships_tbl(i).RELATIONSHIP_ID;
             l_counter_relationships_rec.OBJECT_COUNTER_ID  := p_counter_relationships_tbl(i).OBJECT_COUNTER_ID;
             l_counter_relationships_rec.CTR_ASSOCIATION_ID := p_counter_relationships_tbl(i).CTR_ASSOCIATION_ID;
             l_counter_relationships_rec.RELATIONSHIP_TYPE_CODE := p_counter_relationships_tbl(i).RELATIONSHIP_TYPE_CODE;
             l_counter_relationships_rec.SOURCE_COUNTER_ID  := p_counter_relationships_tbl(i).SOURCE_COUNTER_ID;
             l_counter_relationships_rec.ACTIVE_START_DATE  := p_counter_relationships_tbl(i).ACTIVE_START_DATE ;
             l_counter_relationships_rec.ACTIVE_END_DATE  := p_counter_relationships_tbl(i).ACTIVE_END_DATE;
             l_counter_relationships_rec.BIND_VARIABLE_NAME  := p_counter_relationships_tbl(i).BIND_VARIABLE_NAME;
             l_counter_relationships_rec.FACTOR  := p_counter_relationships_tbl(i).FACTOR;
             l_counter_relationships_rec.object_version_number := p_counter_relationships_tbl(i).object_version_number;
             l_counter_relationships_rec.ATTRIBUTE1     := p_counter_relationships_tbl(i).ATTRIBUTE1;
             l_counter_relationships_rec.ATTRIBUTE2     := p_counter_relationships_tbl(i).ATTRIBUTE2;
             l_counter_relationships_rec.ATTRIBUTE3     := p_counter_relationships_tbl(i).ATTRIBUTE3;
             l_counter_relationships_rec.ATTRIBUTE4     := p_counter_relationships_tbl(i).ATTRIBUTE4;
             l_counter_relationships_rec.ATTRIBUTE5     := p_counter_relationships_tbl(i).ATTRIBUTE5;
             l_counter_relationships_rec.ATTRIBUTE6     := p_counter_relationships_tbl(i).ATTRIBUTE6;
             l_counter_relationships_rec.ATTRIBUTE7     := p_counter_relationships_tbl(i).ATTRIBUTE7;
             l_counter_relationships_rec.ATTRIBUTE8     := p_counter_relationships_tbl(i).ATTRIBUTE8;
             l_counter_relationships_rec.ATTRIBUTE9     := p_counter_relationships_tbl(i).ATTRIBUTE9;
             l_counter_relationships_rec.ATTRIBUTE10    := p_counter_relationships_tbl(i).ATTRIBUTE10;
             l_counter_relationships_rec.ATTRIBUTE11    := p_counter_relationships_tbl(i).ATTRIBUTE11;
             l_counter_relationships_rec.ATTRIBUTE12    := p_counter_relationships_tbl(i).ATTRIBUTE12;
             l_counter_relationships_rec.ATTRIBUTE13    := p_counter_relationships_tbl(i).ATTRIBUTE13;
             l_counter_relationships_rec.ATTRIBUTE14    := p_counter_relationships_tbl(i).ATTRIBUTE14;
             l_counter_relationships_rec.ATTRIBUTE15    := p_counter_relationships_tbl(i).ATTRIBUTE15;
             l_counter_relationships_rec.ATTRIBUTE_CATEGORY  := p_counter_relationships_tbl(i).ATTRIBUTE_CATEGORY;

             IF l_counter_relationships_rec.RELATIONSHIP_ID = FND_API.G_MISS_NUM THEN
               l_counter_relationships_rec.RELATIONSHIP_ID := NULL;
             END IF;

             IF l_counter_relationships_rec.RELATIONSHIP_ID IS NOT NULL THEN
              CSI_COUNTER_TEMPLATE_PVT.update_counter_relationship
            	 (
          	   p_api_version	=>	1.0
           	  ,p_init_msg_list	=>	p_init_msg_list
           	  ,p_commit		=>	p_commit
           	  ,p_validation_level	=>	p_validation_level
              ,p_counter_relationships_rec => l_counter_relationships_rec
           	  ,x_return_status	=>	x_return_status
           	  ,x_msg_count		=>	x_msg_count
           	  ,x_msg_data		=>	x_msg_data
            	 );
             IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                l_msg_index := 1;
                l_msg_count := x_msg_count;

                WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                           FND_API.G_FALSE );
                  csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_TEMPLATE_PVT.UPDATE_COUNTER_RELATIONSHIP API');
                  csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                  l_msg_index := l_msg_index + 1;
                  l_msg_count := l_msg_count - 1;
                END LOOP;
                RAISE FND_API.G_EXC_ERROR;
              END IF;
             ELSE --RELATIONSHIP_ID is null, call to insert counter relationship
              l_counter_relationships_rec.OBJECT_COUNTER_ID := p_counter_instance_rec.counter_id;
              CSI_COUNTER_TEMPLATE_PVT.create_counter_relationship
           	  (
           	   p_api_version	=>	1.0
           	  ,p_init_msg_list	=>	p_init_msg_list
           	  ,p_commit		=>	p_commit
           	  ,p_validation_level	=>	p_validation_level
              ,p_counter_relationships_rec => l_counter_relationships_rec
           	  ,x_return_status	=>	x_return_status
           	  ,x_msg_count		=>	x_msg_count
           	  ,x_msg_data		=>	x_msg_data
           	  );
          	   IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                l_msg_index := 1;
                l_msg_count := x_msg_count;

                WHILE l_msg_count > 0 LOOP
                 x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                            FND_API.G_FALSE );
                 csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_TEMPLATE_PVT.CREATE_COUNTER_RELATIONSHIP API');
                 csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                 l_msg_index := l_msg_index + 1;
                 l_msg_count := l_msg_count - 1;
                END LOOP;
                RAISE FND_API.G_EXC_ERROR;
              END IF;
             END IF;
          END;
       END LOOP;
    END IF;

    -- Update derived filters
    IF p_ctr_derived_filters_tbl.count > 0 THEN

      FOR i in p_ctr_derived_filters_tbl.FIRST..p_ctr_derived_filters_tbl.LAST
       LOOP
         If p_ctr_derived_filters_tbl(i).counter_id is null then
             p_ctr_derived_filters_tbl(i).counter_id := p_counter_instance_rec.counter_id;
         End if;
       END LOOP;

             CSI_COUNTER_TEMPLATE_PVT.update_derived_filters
           	 (
           	   p_api_version	=>	1.0
           	  ,p_init_msg_list	=>	p_init_msg_list
           	  ,p_commit		=>	p_commit
           	  ,p_validation_level	=>	p_validation_level
              ,p_ctr_derived_filters_tbl => p_ctr_derived_filters_tbl
           	  ,x_return_status	=>	x_return_status
           	  ,x_msg_count		=>	x_msg_count
           	  ,x_msg_data		=>	x_msg_data
           	 );
             IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                l_msg_index := 1;
                l_msg_count := x_msg_count;

                WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                           FND_API.G_FALSE );
                  csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_TEMPLATE_PVT.UPDATE_DERIVED_FILTERS API');
                  csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                  l_msg_index := l_msg_index + 1;
                  l_msg_count := l_msg_count - 1;
                END LOOP;
                RAISE FND_API.G_EXC_ERROR;
              END IF;
    END IF;
    -- Update Counter associations

    IF p_counter_associations_tbl.count > 0 THEN
       FOR i in p_counter_associations_tbl.FIRST..p_counter_associations_tbl.LAST
       LOOP
          DECLARE l_instance_association_id NUMBER;
          BEGIN
             l_counter_associations_rec.instance_association_id := p_counter_associations_tbl(i).instance_association_id;
             l_counter_associations_rec.COUNTER_ID  := p_counter_associations_tbl(i).counter_id;
             l_counter_associations_rec.SOURCE_OBJECT_CODE := p_counter_associations_tbl(i).SOURCE_OBJECT_CODE;
             l_counter_associations_rec.SOURCE_OBJECT_ID := p_counter_associations_tbl(i).SOURCE_OBJECT_ID;
             l_counter_associations_rec.START_DATE_ACTIVE  := p_counter_associations_tbl(i).START_DATE_ACTIVE ;
             l_counter_associations_rec.END_DATE_ACTIVE  := p_counter_associations_tbl(i).END_DATE_ACTIVE;
             l_counter_associations_rec.OBJECT_VERSION_NUMBER := p_counter_associations_tbl(i).OBJECT_VERSION_NUMBER;
             l_counter_associations_rec.ATTRIBUTE1     := p_counter_associations_tbl(i).ATTRIBUTE1;
             l_counter_associations_rec.ATTRIBUTE2     := p_counter_associations_tbl(i).ATTRIBUTE2;
             l_counter_associations_rec.ATTRIBUTE3     := p_counter_associations_tbl(i).ATTRIBUTE3;
             l_counter_associations_rec.ATTRIBUTE4     := p_counter_associations_tbl(i).ATTRIBUTE4;
             l_counter_associations_rec.ATTRIBUTE5     := p_counter_associations_tbl(i).ATTRIBUTE5;
             l_counter_associations_rec.ATTRIBUTE6     := p_counter_associations_tbl(i).ATTRIBUTE6;
             l_counter_associations_rec.ATTRIBUTE7     := p_counter_associations_tbl(i).ATTRIBUTE7;
             l_counter_associations_rec.ATTRIBUTE8     := p_counter_associations_tbl(i).ATTRIBUTE8;
             l_counter_associations_rec.ATTRIBUTE9     := p_counter_associations_tbl(i).ATTRIBUTE9;
             l_counter_associations_rec.ATTRIBUTE10    := p_counter_associations_tbl(i).ATTRIBUTE10;
             l_counter_associations_rec.ATTRIBUTE11    := p_counter_associations_tbl(i).ATTRIBUTE11;
             l_counter_associations_rec.ATTRIBUTE12    := p_counter_associations_tbl(i).ATTRIBUTE12;
             l_counter_associations_rec.ATTRIBUTE13    := p_counter_associations_tbl(i).ATTRIBUTE13;
             l_counter_associations_rec.ATTRIBUTE14    := p_counter_associations_tbl(i).ATTRIBUTE14;
             l_counter_associations_rec.ATTRIBUTE15    := p_counter_associations_tbl(i).ATTRIBUTE15;
             l_counter_associations_rec.ATTRIBUTE_CATEGORY  := p_counter_associations_tbl(i).ATTRIBUTE_CATEGORY;
             l_counter_associations_rec.maint_organization_id := p_counter_associations_tbl(i).maint_organization_id;
             l_counter_associations_rec.primary_failure_flag := p_counter_associations_tbl(i).primary_failure_flag;

             IF l_counter_associations_rec.instance_association_id = FND_API.G_MISS_NUM THEN
                l_counter_associations_rec.instance_association_id := NULL;
             END IF;

             IF l_counter_associations_rec.instance_association_id IS NOT NULL THEN
              CSI_COUNTER_PVT.update_ctr_associations
            	 (
           	   p_api_version	=>	1.0
           	  ,p_init_msg_list	=>	p_init_msg_list
           	  ,p_commit		=>	p_commit
           	  ,p_validation_level	=>	p_validation_level
              ,p_counter_associations_rec => l_counter_associations_rec
           	  ,x_return_status	=>	x_return_status
           	  ,x_msg_count		=>	x_msg_count
           	  ,x_msg_data		=>	x_msg_data
            	 );
              IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                l_msg_index := 1;
                l_msg_count := x_msg_count;

                WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                           FND_API.G_FALSE );
                  csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_PVT.UPDATE_CTR_ASSOCIATIONS API');
                  csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                  l_msg_index := l_msg_index + 1;
                  l_msg_count := l_msg_count - 1;
                END LOOP;
                RAISE FND_API.G_EXC_ERROR;
              END IF;
             ELSE --instance_association_id is null. insert new counter association
              l_counter_associations_rec.COUNTER_ID  := p_counter_instance_rec.counter_id;
              CSI_COUNTER_PVT.create_ctr_associations
           	  (
           	   p_api_version	=>	1.0
           	  ,p_init_msg_list	=>	p_init_msg_list
           	  ,p_commit		=>	p_commit
           	  ,p_validation_level	=>	p_validation_level
              ,p_counter_associations_rec => l_counter_associations_rec
           	  ,x_return_status	=>	x_return_status
           	  ,x_msg_count		=>	x_msg_count
           	  ,x_msg_data		=>	x_msg_data
           	  ,x_instance_association_id	=>	l_instance_association_id
           	  );
          	   IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                l_msg_index := 1;
                l_msg_count := x_msg_count;

                WHILE l_msg_count > 0 LOOP
                 x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                            FND_API.G_FALSE );
                 csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_PVT.CREATE_CTR_ASSOCIATIONS API');
                 csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                 l_msg_index := l_msg_index + 1;
                 l_msg_count := l_msg_count - 1;
                END LOOP;
                RAISE FND_API.G_EXC_ERROR;
              END IF;
             END IF;
          END;
       END LOOP;
    END IF;


    -- End of API body

   /* Customer post -processing  section - Mandatory  */
   IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'C' )  ) THEN
     CSI_COUNTER_CUHK.update_counter_post
     (
      p_api_version	            => p_api_version
      ,p_init_msg_list	            => p_init_msg_list
      ,p_commit		            => p_commit
      ,p_validation_level           => p_validation_level
      ,p_counter_instance_rec       => p_counter_instance_rec
      ,P_ctr_properties_tbl         => P_ctr_properties_tbl
      ,P_counter_relationships_tbl  => P_counter_relationships_tbl
      ,P_ctr_derived_filters_tbl    => P_ctr_derived_filters_tbl
      --,P_counter_associations_tbl   => P_counter_associations_tbl
      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
     );
     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;

         WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                           FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_CUHK.UPDATE_COUNTER_POST API');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;
   /* Vertical post -processing  section - Mandatory  */
   IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'V' )  ) THEN
     CSI_COUNTER_VUHK.update_counter_post
     (
      p_api_version	            => p_api_version
      ,p_init_msg_list	            => p_init_msg_list
      ,p_commit		            => p_commit
      ,p_validation_level           => p_validation_level
      ,p_counter_instance_rec       => p_counter_instance_rec
      ,P_ctr_properties_tbl         => P_ctr_properties_tbl
      ,P_counter_relationships_tbl  => P_counter_relationships_tbl
      ,P_ctr_derived_filters_tbl    => P_ctr_derived_filters_tbl
      --,P_counter_associations_tbl   => P_counter_associations_tbl
      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
     );
     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;

         WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                           FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_VUHK.UPDATE_COUNTER_POST API');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean(nvl(p_commit,FND_API.G_FALSE)) THEN
       COMMIT WORK;
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO update_counter_pub;
      FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count,
                 p_data  => x_msg_data
                );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_counter_pub;
      FND_MSG_PUB.Count_And_Get
      		(p_count => x_msg_count,
                 p_data  => x_msg_data
                );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_counter_pub;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
            (G_PKG_NAME,
             l_api_name
            );
       END IF;
       FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data
            );

END update_counter;

--|---------------------------------------------------
--| procedure name: update_ctr_property
--| description :   procedure used to
--|                 update counter properties
--|---------------------------------------------------

PROCEDURE update_ctr_property
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,P_ctr_properties_tbl        IN out NOCOPY CSI_CTR_DATASTRUCTURES_PUB.Ctr_properties_tbl
    ,x_return_status             OUT    NOCOPY VARCHAR2
    ,x_msg_count                 OUT    NOCOPY NUMBER
    ,x_msg_data                  OUT    NOCOPY VARCHAR2
 )
 IS
    l_api_name                      CONSTANT VARCHAR2(30)   := 'UPDATE_CTR_PROPERTY';
    l_api_version                   CONSTANT NUMBER         := 1.0;
    -- l_debug_level                   NUMBER;
    l_flag                          VARCHAR2(1)             := 'N';
    l_msg_data                      VARCHAR2(2000);
    l_msg_index                     NUMBER;
    l_msg_count                     NUMBER;
    l_count                         NUMBER;
    l_return_message                VARCHAR2(100);

    l_Ctr_properties_rec            CSI_CTR_DATASTRUCTURES_PUB.Ctr_properties_rec;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  update_ctr_property_pub;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   -- Check the profile option debug_level for debug message reporting
   -- l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

   -- If debug_level = 1 then dump the procedure name
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'update_ctr_property');
   END IF;

   -- If the debug level = 2 then dump all the parameters values.
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 1) THEN
      csi_ctr_gen_utility_pvt.put_line( 'update_ctr_property'     ||
                                     p_api_version         ||'-'||
                                     p_commit              ||'-'||
                                     p_init_msg_list       ||'-'||
                                     p_validation_level );
      csi_ctr_gen_utility_pvt.dump_ctr_properties_tbl(p_ctr_properties_tbl);
   END IF;

   /* Customer pre -processing  section - Mandatory  */
   IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'C' )  ) THEN
     CSI_COUNTER_CUHK.update_ctr_property_pre
     (
      p_api_version	                => p_api_version
      ,p_init_msg_list	             => p_init_msg_list
      ,p_commit		                   => p_commit
      ,p_validation_level           => p_validation_level
      ,P_ctr_properties_tbl 	       => P_ctr_properties_tbl
      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
     );
     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;

         WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                           FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_CUHK.UPDATE_CTR_PROPERTY_PRE API');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;
   /* Vertical pre -processing  section - Mandatory  */
   IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' )  ) THEN
     CSI_COUNTER_VUHK.update_ctr_property_pre
     (
      p_api_version	                => p_api_version
      ,p_init_msg_list	             => p_init_msg_list
      ,p_commit		                   => p_commit
      ,p_validation_level           => p_validation_level
      ,P_ctr_properties_tbl 	       => P_ctr_properties_tbl
      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
     );
     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;

         WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                           FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_VUHK.UPDATE_CTR_PROPERTY_PRE API');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;

   -- Start of API Body

   IF p_ctr_properties_tbl.count > 0 THEN
       FOR j in p_ctr_properties_tbl.FIRST..p_ctr_properties_tbl.LAST
       LOOP
          BEGIN
             l_Ctr_properties_rec.COUNTER_PROPERTY_ID := p_ctr_properties_tbl(j).COUNTER_PROPERTY_ID;
             l_Ctr_properties_rec.counter_id := p_ctr_properties_tbl(j).counter_id;
             l_Ctr_properties_rec.NAME := p_ctr_properties_tbl(j).name;
             l_Ctr_properties_rec.DESCRIPTION  := p_ctr_properties_tbl(j).DESCRIPTION;
             l_Ctr_properties_rec.PROPERTY_DATA_TYPE := p_ctr_properties_tbl(j).PROPERTY_DATA_TYPE;
             l_Ctr_properties_rec.IS_NULLABLE  := p_ctr_properties_tbl(j).IS_NULLABLE;
             l_Ctr_properties_rec.DEFAULT_VALUE  := p_ctr_properties_tbl(j).DEFAULT_VALUE;
             l_Ctr_properties_rec.MINIMUM_VALUE  := p_ctr_properties_tbl(j).MINIMUM_VALUE;
             l_Ctr_properties_rec.MAXIMUM_VALUE  := p_ctr_properties_tbl(j).MAXIMUM_VALUE;
             l_Ctr_properties_rec.UOM_CODE       := p_ctr_properties_tbl(j).UOM_CODE;
             l_Ctr_properties_rec.START_DATE_ACTIVE  := p_ctr_properties_tbl(j).START_DATE_ACTIVE;
             l_Ctr_properties_rec.END_DATE_ACTIVE    := p_ctr_properties_tbl(j).END_DATE_ACTIVE;
             l_Ctr_properties_rec.PROPERTY_LOV_TYPE  := p_ctr_properties_tbl(j).PROPERTY_LOV_TYPE;
             l_Ctr_properties_rec.OBJECT_VERSION_NUMBER := p_ctr_properties_tbl(j).OBJECT_VERSION_NUMBER;
             l_Ctr_properties_rec.ATTRIBUTE1     := p_ctr_properties_tbl(j).ATTRIBUTE1;
             l_Ctr_properties_rec.ATTRIBUTE2     := p_ctr_properties_tbl(j).ATTRIBUTE2;
             l_Ctr_properties_rec.ATTRIBUTE3     := p_ctr_properties_tbl(j).ATTRIBUTE3;
             l_Ctr_properties_rec.ATTRIBUTE4     := p_ctr_properties_tbl(j).ATTRIBUTE4;
             l_Ctr_properties_rec.ATTRIBUTE5     := p_ctr_properties_tbl(j).ATTRIBUTE5;
             l_Ctr_properties_rec.ATTRIBUTE6     := p_ctr_properties_tbl(j).ATTRIBUTE6;
             l_Ctr_properties_rec.ATTRIBUTE7     := p_ctr_properties_tbl(j).ATTRIBUTE7;
             l_Ctr_properties_rec.ATTRIBUTE8     := p_ctr_properties_tbl(j).ATTRIBUTE8;
             l_Ctr_properties_rec.ATTRIBUTE9     := p_ctr_properties_tbl(j).ATTRIBUTE9;
             l_Ctr_properties_rec.ATTRIBUTE10    := p_ctr_properties_tbl(j).ATTRIBUTE10;
             l_Ctr_properties_rec.ATTRIBUTE11    := p_ctr_properties_tbl(j).ATTRIBUTE11;
             l_Ctr_properties_rec.ATTRIBUTE12    := p_ctr_properties_tbl(j).ATTRIBUTE12;
             l_Ctr_properties_rec.ATTRIBUTE13    := p_ctr_properties_tbl(j).ATTRIBUTE13;
             l_Ctr_properties_rec.ATTRIBUTE14    := p_ctr_properties_tbl(j).ATTRIBUTE14;
             l_Ctr_properties_rec.ATTRIBUTE15    := p_ctr_properties_tbl(j).ATTRIBUTE15;
             l_Ctr_properties_rec.ATTRIBUTE_CATEGORY  := p_ctr_properties_tbl(j).ATTRIBUTE_CATEGORY;


             CSI_COUNTER_PVT.update_ctr_property
           	 (
           	   p_api_version	=> 1.0
           	  ,p_init_msg_list	=> p_init_msg_list
           	  ,p_commit		=> p_commit
           	  ,p_validation_level	=> p_validation_level
                  ,p_ctr_properties_rec => l_ctr_properties_rec
           	  ,x_return_status	=> x_return_status
           	  ,x_msg_count		=> x_msg_count
           	  ,x_msg_data		=> x_msg_data
           	  );
              IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                l_msg_index := 1;
                l_msg_count := x_msg_count;

                WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                           FND_API.G_FALSE );
                  csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_PVT.UPDATE_CTR_PROPERTY API');
                  csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                  l_msg_index := l_msg_index + 1;
                  l_msg_count := l_msg_count - 1;
               END LOOP;
               RAISE FND_API.G_EXC_ERROR;
             END IF;
          END;
       END LOOP;
    END IF;

    -- End of API body

   /* Customer post -processing  section - Mandatory  */
   IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'C' )  ) THEN
     CSI_COUNTER_CUHK.update_ctr_property_post
     (
      p_api_version	                => p_api_version
      ,p_init_msg_list	             => p_init_msg_list
      ,p_commit		                   => p_commit
      ,p_validation_level           => p_validation_level
      ,P_ctr_properties_tbl 	       => P_ctr_properties_tbl
      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
     );
     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;

         WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                           FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_CUHK.UPDATE_CTR_PROPERTY_POST API');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;
   /* Vertical post -processing  section - Mandatory  */
   IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'V' )  ) THEN
     CSI_COUNTER_VUHK.update_ctr_property_post
     (
      p_api_version	                => p_api_version
      ,p_init_msg_list	             => p_init_msg_list
      ,p_commit		                   => p_commit
      ,p_validation_level           => p_validation_level
      ,P_ctr_properties_tbl 	       => P_ctr_properties_tbl
      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
     );
     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;

         WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                           FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_VUHK.UPDATE_CTR_PROPERTY_POST API');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean(nvl(p_commit,FND_API.G_FALSE)) THEN
       COMMIT WORK;
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO update_ctr_property_pub;
      FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count,
                 p_data  => x_msg_data
                );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_ctr_property_pub;
      FND_MSG_PUB.Count_And_Get
      		(p_count => x_msg_count,
                 p_data  => x_msg_data
                );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_ctr_property_pub;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
            (G_PKG_NAME,
             l_api_name
            );
       END IF;
       FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data
            );

END update_ctr_property;

PROCEDURE update_ctr_associations
 (
   p_api_version               IN     NUMBER
  ,p_commit                    IN     VARCHAR2
  ,p_init_msg_list             IN     VARCHAR2
  ,p_validation_level          IN     NUMBER
  ,p_counter_associations_tbl  IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.counter_associations_tbl
  ,x_return_status                OUT    NOCOPY VARCHAR2
  ,x_msg_count                    OUT    NOCOPY NUMBER
  ,x_msg_data                     OUT    NOCOPY VARCHAR2
 )
IS
    l_api_name                      CONSTANT VARCHAR2(30)   := 'UPDATE_CTR_ASSOCIATIONS';
    l_api_version                   CONSTANT NUMBER         := 1.0;
    -- l_debug_level                   NUMBER;
    l_flag                          VARCHAR2(1)             := 'N';
    l_msg_data                      VARCHAR2(2000);
    l_msg_index                     NUMBER;
    l_msg_count                     NUMBER;
    l_count                         NUMBER;
    l_return_message                VARCHAR2(100);

    l_counter_associations_rec      CSI_CTR_DATASTRUCTURES_PUB.counter_associations_rec;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT update_ctr_associations_pub;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME   )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(nvl(p_init_msg_list,FND_API.G_FALSE)) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Read the debug profiles values in to global variable 7197402
   CSI_CTR_GEN_UTILITY_PVT.read_debug_profiles;

   -- Check the profile option debug_level for debug message reporting
   -- l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

   -- If debug_level = 1 then dump the procedure name
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 0) THEN
      csi_ctr_gen_utility_pvt.put_line( 'update_ctr_associations');
   END IF;

   -- If the debug level = 2 then dump all the parameters values.
   IF (CSI_CTR_GEN_UTILITY_PVT.g_debug_level > 1) THEN
      csi_ctr_gen_utility_pvt.put_line( 'update_ctr_associations'     ||
                                     p_api_version         ||'-'||
                                     p_commit              ||'-'||
                                     p_init_msg_list       ||'-'||
                                     p_validation_level );
      csi_ctr_gen_utility_pvt.dump_counter_associations_tbl(p_counter_associations_tbl);
   END IF;

   /* Customer pre -processing  section - Mandatory  */
   IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'C' )  ) THEN
     CSI_COUNTER_CUHK.update_ctr_associations_pre
     (
       p_api_version	           => p_api_version
      ,p_init_msg_list	           => p_init_msg_list
      ,p_commit		           => p_commit
      ,p_validation_level          => p_validation_level
      ,P_counter_associations_tbl  => P_counter_associations_tbl
      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
     );
     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;

         WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                           FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_CUHK.UPDATE_CTR_ASSOCIATIONS_PRE API');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;

   /* Vertical pre -processing  section - Mandatory  */
   IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' )  ) THEN
     CSI_COUNTER_VUHK.update_ctr_associations_pre
     (
       p_api_version               => p_api_version
      ,p_init_msg_list             => p_init_msg_list
      ,p_commit                    => p_commit
      ,p_validation_level          => p_validation_level
      ,P_counter_associations_tbl  => P_counter_associations_tbl
      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
     );
     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;

         WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                           FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_CUHK.UPDATE_CTR_ASSOCIATIONS_PRE API');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;

   -- Start of API Body

   IF p_counter_associations_tbl.count > 0 THEN
       FOR i in p_counter_associations_tbl.FIRST..p_counter_associations_tbl.LAST
       LOOP
          BEGIN
             l_counter_associations_rec.instance_association_id := p_counter_associations_tbl(i).instance_association_id;
             l_counter_associations_rec.COUNTER_ID  := p_counter_associations_tbl(i).counter_id;
             l_counter_associations_rec.SOURCE_OBJECT_CODE := p_counter_associations_tbl(i).SOURCE_OBJECT_CODE;
             l_counter_associations_rec.SOURCE_OBJECT_ID := p_counter_associations_tbl(i).SOURCE_OBJECT_ID;
             l_counter_associations_rec.START_DATE_ACTIVE  := p_counter_associations_tbl(i).START_DATE_ACTIVE ;
             l_counter_associations_rec.END_DATE_ACTIVE  := p_counter_associations_tbl(i).END_DATE_ACTIVE;
             l_counter_associations_rec.OBJECT_VERSION_NUMBER := p_counter_associations_tbl(i).OBJECT_VERSION_NUMBER;
             l_counter_associations_rec.ATTRIBUTE1     := p_counter_associations_tbl(i).ATTRIBUTE1;
             l_counter_associations_rec.ATTRIBUTE2     := p_counter_associations_tbl(i).ATTRIBUTE2;
             l_counter_associations_rec.ATTRIBUTE3     := p_counter_associations_tbl(i).ATTRIBUTE3;
             l_counter_associations_rec.ATTRIBUTE4     := p_counter_associations_tbl(i).ATTRIBUTE4;
             l_counter_associations_rec.ATTRIBUTE5     := p_counter_associations_tbl(i).ATTRIBUTE5;
             l_counter_associations_rec.ATTRIBUTE6     := p_counter_associations_tbl(i).ATTRIBUTE6;
             l_counter_associations_rec.ATTRIBUTE7     := p_counter_associations_tbl(i).ATTRIBUTE7;
             l_counter_associations_rec.ATTRIBUTE8     := p_counter_associations_tbl(i).ATTRIBUTE8;
             l_counter_associations_rec.ATTRIBUTE9     := p_counter_associations_tbl(i).ATTRIBUTE9;
             l_counter_associations_rec.ATTRIBUTE10    := p_counter_associations_tbl(i).ATTRIBUTE10;
             l_counter_associations_rec.ATTRIBUTE11    := p_counter_associations_tbl(i).ATTRIBUTE11;
             l_counter_associations_rec.ATTRIBUTE12    := p_counter_associations_tbl(i).ATTRIBUTE12;
             l_counter_associations_rec.ATTRIBUTE13    := p_counter_associations_tbl(i).ATTRIBUTE13;
             l_counter_associations_rec.ATTRIBUTE14    := p_counter_associations_tbl(i).ATTRIBUTE14;
             l_counter_associations_rec.ATTRIBUTE15    := p_counter_associations_tbl(i).ATTRIBUTE15;
             l_counter_associations_rec.ATTRIBUTE_CATEGORY  := p_counter_associations_tbl(i).ATTRIBUTE_CATEGORY;
             l_counter_associations_rec.maint_organization_id := p_counter_associations_tbl(i).maint_organization_id;
             l_counter_associations_rec.primary_failure_flag := p_counter_associations_tbl(i).primary_failure_flag;

             CSI_COUNTER_PVT.update_ctr_associations
           	 (
           	   p_api_version	=>	1.0
           	  ,p_init_msg_list	=>	p_init_msg_list
           	  ,p_commit		=>	p_commit
           	  ,p_validation_level	=>	p_validation_level
                  ,p_counter_associations_rec => l_counter_associations_rec
           	  ,x_return_status	=>	x_return_status
           	  ,x_msg_count		=>	x_msg_count
           	  ,x_msg_data		=>	x_msg_data
           	 );
             IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                l_msg_index := 1;
                l_msg_count := x_msg_count;

                WHILE l_msg_count > 0 LOOP
                  x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                           FND_API.G_FALSE );
                  csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_PVT.UPDATE_CTR_ASSOCIATIONS API');
                  csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
                  l_msg_index := l_msg_index + 1;
                  l_msg_count := l_msg_count - 1;
                END LOOP;
                RAISE FND_API.G_EXC_ERROR;
              END IF;
          END;
       END LOOP;
    END IF;

    -- End of API body

    /* Customer post -processing  section - Mandatory  */
   IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'A', 'C' )  ) THEN
     CSI_COUNTER_CUHK.update_ctr_associations_post
     (
       p_api_version               => p_api_version
      ,p_init_msg_list             => p_init_msg_list
      ,p_commit                    => p_commit
      ,p_validation_level          => p_validation_level
      ,P_counter_associations_tbl  => P_counter_associations_tbl
      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
     );
     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;

         WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                           FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_CUHK.UPDATE_CTR_ASSOCIATIONS_POST API');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;

   /* Vertical pre -processing  section - Mandatory  */
   IF  ( JTF_USR_HKS.Ok_to_execute(  G_PKG_NAME, l_api_name, 'B', 'V' )  ) THEN
     CSI_COUNTER_VUHK.update_ctr_associations_post
     (
       p_api_version               => p_api_version
      ,p_init_msg_list             => p_init_msg_list
      ,p_commit                    => p_commit
      ,p_validation_level          => p_validation_level
      ,P_counter_associations_tbl  => P_counter_associations_tbl
      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
     );
     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         l_msg_index := 1;
         l_msg_count := x_msg_count;

         WHILE l_msg_count > 0 LOOP
             x_msg_data := FND_MSG_PUB.GET
                           (l_msg_index,
                           FND_API.G_FALSE );
             csi_ctr_gen_utility_pvt.put_line( ' Error from CSI_COUNTER_CUHK.UPDATE_CTR_ASSOCIATIONS_POST API');
             csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
             l_msg_index := l_msg_index + 1;
             l_msg_count := l_msg_count - 1;
         END LOOP;
         RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean(nvl(p_commit,FND_API.G_FALSE)) THEN
       COMMIT WORK;
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO update_ctr_associations_pub;
      FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count,
                 p_data  => x_msg_data
                );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_ctr_associations_pub;
      FND_MSG_PUB.Count_And_Get
      		(p_count => x_msg_count,
                 p_data  => x_msg_data
                );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO update_ctr_associations_pub;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
            (G_PKG_NAME,
             l_api_name
            );
       END IF;
       FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data
            );

END update_ctr_associations;



END CSI_COUNTER_PUB;

/
