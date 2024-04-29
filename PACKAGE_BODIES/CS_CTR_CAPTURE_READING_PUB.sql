--------------------------------------------------------
--  DDL for Package Body CS_CTR_CAPTURE_READING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_CTR_CAPTURE_READING_PUB" as
-- $Header: csxpcrdb.pls 120.2.12010000.2 2009/04/17 14:23:18 ngoutam ship $
-- Start of Comments
-- Package name     : CS_CAPTURE_READING_PUB
-- Purpose          : Capture readings for counters
-- History          :
-- NOTE             :
-- End of Comments
G_PKG_NAME CONSTANT VARCHAR2(30):= 'CS_CTR_CAPTURE_READING_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csxpcrdb.pls';

PROCEDURE Capture_Counter_Reading(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_CTR_GRP_LOG_Rec            IN   CTR_GRP_LOG_Rec_Type,
    p_CTR_RDG_Tbl                IN   CTR_RDG_Tbl_Type,
    p_PROP_RDG_Tbl               IN   PROP_RDG_Tbl_Type,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
 )
IS
   l_api_name                CONSTANT VARCHAR2(30) := 'CAPTURE_COUNTER_READING';
   l_api_version_number      CONSTANT NUMBER   := 1.0;
   l_return_status_full      VARCHAR2(1);
   l_ctr_grp_log_id          NUMBER;
   l_array_counter           NUMBER;
   l_txn_tbl                 csi_datastructures_pub.transaction_tbl;
   l_ctr_rdg_tbl             csi_ctr_datastructures_pub.counter_readings_tbl;
   --
   l_ctr_prop_rdg_tbl        csi_ctr_datastructures_pub.ctr_property_readings_tbl;
   --
   l_counter_id              NUMBER;
   l_rdg_count               NUMBER := 0;
   l_prop_rdg_count          NUMBER := 0;
   l_msg_index               NUMBER;
   l_msg_count               NUMBER;
   l_empty_txn               VARCHAR2(1);
   l_src_obj_code            CSI_COUNTER_ASSOCIATIONS.source_object_code%TYPE;
   l_src_obj_id              NUMBER;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT CS_CTR_CAPTURE_READING_PUB;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
					p_api_version_number,
					l_api_name,
					G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --
   IF p_ctr_rdg_tbl.count = 0 THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      csi_ctr_gen_utility_pvt.put_line('No Counter Readings captured...');
      Return;
   END IF;
   --
   IF NVL(p_ctr_grp_log_rec.source_transaction_code,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
      IF p_ctr_grp_log_rec.source_transaction_code in ('CP','INTERNAL') THEN
	 l_txn_tbl(1).transaction_type_id := 80;
      ELSIF p_ctr_grp_log_rec.source_transaction_code = 'CONTRACT_LINE' THEN
	 l_txn_tbl(1).transaction_type_id := 81;
      ELSIF p_ctr_grp_log_rec.source_transaction_code = 'OKL_CNTR_GRP' THEN
	 l_txn_tbl(1).transaction_type_id := 85;
      ELSIF p_ctr_grp_log_rec.source_transaction_code = 'FS' THEN
         l_txn_tbl(1).transaction_type_id := 86;
      ELSIF p_ctr_grp_log_rec.source_transaction_code = 'DR' THEN
         l_txn_tbl(1).transaction_type_id := 87;
      ELSE
	 csi_ctr_gen_utility_pvt.put_line('Invalid Source Transaction Code : '||p_ctr_grp_log_rec.source_transaction_code);
	 csi_ctr_gen_utility_pvt.ExitWithErrMsg('CS_API_CTR_SRC_TXN_INFO_REQD');
      END IF;
      --
      l_txn_tbl(1).source_header_ref_id := p_CTR_GRP_LOG_Rec.source_transaction_id;
      l_txn_tbl(1).source_transaction_date := sysdate;
      l_txn_tbl(1).ATTRIBUTE1 := p_CTR_GRP_LOG_Rec.ATTRIBUTE1;
      l_txn_tbl(1).ATTRIBUTE2 := p_CTR_GRP_LOG_Rec.ATTRIBUTE2;
      l_txn_tbl(1).ATTRIBUTE3 := p_CTR_GRP_LOG_Rec.ATTRIBUTE3;
      l_txn_tbl(1).ATTRIBUTE4 := p_CTR_GRP_LOG_Rec.ATTRIBUTE4;
      l_txn_tbl(1).ATTRIBUTE5 := p_CTR_GRP_LOG_Rec.ATTRIBUTE5;
      l_txn_tbl(1).ATTRIBUTE6 := p_CTR_GRP_LOG_Rec.ATTRIBUTE6;
      l_txn_tbl(1).ATTRIBUTE7 := p_CTR_GRP_LOG_Rec.ATTRIBUTE7;
      l_txn_tbl(1).ATTRIBUTE8 := p_CTR_GRP_LOG_Rec.ATTRIBUTE8;
      l_txn_tbl(1).ATTRIBUTE9 := p_CTR_GRP_LOG_Rec.ATTRIBUTE9;
      l_txn_tbl(1).ATTRIBUTE10 := p_CTR_GRP_LOG_Rec.ATTRIBUTE10;
      l_txn_tbl(1).ATTRIBUTE11 := p_CTR_GRP_LOG_Rec.ATTRIBUTE11;
      l_txn_tbl(1).ATTRIBUTE12 := p_CTR_GRP_LOG_Rec.ATTRIBUTE12;
      l_txn_tbl(1).ATTRIBUTE13 := p_CTR_GRP_LOG_Rec.ATTRIBUTE13;
      l_txn_tbl(1).ATTRIBUTE14 := p_CTR_GRP_LOG_Rec.ATTRIBUTE14;
      l_txn_tbl(1).ATTRIBUTE15 := p_CTR_GRP_LOG_Rec.ATTRIBUTE15;
      l_txn_tbl(1).CONTEXT := p_CTR_GRP_LOG_Rec.CONTEXT;
      l_empty_txn := 'N';
   ELSE
      l_txn_tbl.DELETE;
      l_empty_txn := 'Y';
   END IF; -- Group Log Source Txn code check
   --
   l_array_counter := p_CTR_RDG_Tbl.First;
   WHILE p_ctr_rdg_tbl.EXISTS(l_array_counter) LOOP
      l_rdg_count := l_rdg_count + 1;
      l_ctr_rdg_tbl(l_rdg_count).COUNTER_VALUE_ID := p_ctr_rdg_tbl(l_array_counter).counter_value_id;
      l_ctr_rdg_tbl(l_rdg_count).COUNTER_ID := p_ctr_rdg_tbl(l_array_counter).counter_id;
      l_ctr_rdg_tbl(l_rdg_count).VALUE_TIMESTAMP  := p_ctr_rdg_tbl(l_array_counter).VALUE_TIMESTAMP;
      l_ctr_rdg_tbl(l_rdg_count).COUNTER_READING := p_ctr_rdg_tbl(l_array_counter).COUNTER_READING ;
      --
      IF NVL(p_ctr_rdg_tbl(l_array_counter).RESET_FLAG,'N') = 'Y' THEN
	 l_ctr_rdg_tbl(l_rdg_count).RESET_MODE  := 'SOFT';
      ELSE
	 l_ctr_rdg_tbl(l_rdg_count).RESET_MODE  := NULL;
      END IF;
      --
      l_ctr_rdg_tbl(l_rdg_count).RESET_REASON  := p_ctr_rdg_tbl(l_array_counter).RESET_REASON;
      l_ctr_rdg_tbl(l_rdg_count).RESET_COUNTER_READING :=p_ctr_rdg_tbl(l_array_counter).POST_RESET_FIRST_RDG;
      l_ctr_rdg_tbl(l_rdg_count).ADJUSTMENT_TYPE  := p_ctr_rdg_tbl(l_array_counter).MISC_READING_TYPE;
      l_ctr_rdg_tbl(l_rdg_count).ADJUSTMENT_READING   := p_ctr_rdg_tbl(l_array_counter).MISC_READING ;
      l_ctr_rdg_tbl(l_rdg_count).ATTRIBUTE1 := p_ctr_rdg_tbl(l_array_counter).ATTRIBUTE1;
      l_ctr_rdg_tbl(l_rdg_count).ATTRIBUTE2 := p_ctr_rdg_tbl(l_array_counter).ATTRIBUTE2;
      l_ctr_rdg_tbl(l_rdg_count).ATTRIBUTE3 := p_ctr_rdg_tbl(l_array_counter).ATTRIBUTE3;
      l_ctr_rdg_tbl(l_rdg_count).ATTRIBUTE4 := p_ctr_rdg_tbl(l_array_counter).ATTRIBUTE4;
      l_ctr_rdg_tbl(l_rdg_count).ATTRIBUTE5 := p_ctr_rdg_tbl(l_array_counter).ATTRIBUTE5;
      l_ctr_rdg_tbl(l_rdg_count).ATTRIBUTE6 := p_ctr_rdg_tbl(l_array_counter).ATTRIBUTE6;
      l_ctr_rdg_tbl(l_rdg_count).ATTRIBUTE7 := p_ctr_rdg_tbl(l_array_counter).ATTRIBUTE7;
      l_ctr_rdg_tbl(l_rdg_count).ATTRIBUTE8 := p_ctr_rdg_tbl(l_array_counter).ATTRIBUTE8;
      l_ctr_rdg_tbl(l_rdg_count).ATTRIBUTE9 := p_ctr_rdg_tbl(l_array_counter).ATTRIBUTE9;
      l_ctr_rdg_tbl(l_rdg_count).ATTRIBUTE10 := p_ctr_rdg_tbl(l_array_counter).ATTRIBUTE10;
      l_ctr_rdg_tbl(l_rdg_count).ATTRIBUTE11 := p_ctr_rdg_tbl(l_array_counter).ATTRIBUTE11;
      l_ctr_rdg_tbl(l_rdg_count).ATTRIBUTE12 := p_ctr_rdg_tbl(l_array_counter).ATTRIBUTE12;
      l_ctr_rdg_tbl(l_rdg_count).ATTRIBUTE13 := p_ctr_rdg_tbl(l_array_counter).ATTRIBUTE13;
      l_ctr_rdg_tbl(l_rdg_count).ATTRIBUTE14 := p_ctr_rdg_tbl(l_array_counter).ATTRIBUTE14;
      l_ctr_rdg_tbl(l_rdg_count).ATTRIBUTE15 := p_ctr_rdg_tbl(l_array_counter).ATTRIBUTE15;
      l_ctr_rdg_tbl(l_rdg_count).ATTRIBUTE_CATEGORY := p_ctr_rdg_tbl(l_array_counter).CONTEXT;
      l_ctr_rdg_tbl(l_rdg_count).COMMENTS     := p_ctr_rdg_tbl(l_array_counter).COMMENTS;
      l_ctr_rdg_tbl(l_rdg_count).DISABLED_FLAG := p_ctr_rdg_tbl(l_array_counter).OVERRIDE_VALID_FLAG;
      --
      IF l_empty_txn = 'N' THEN
         l_ctr_rdg_tbl(l_rdg_count).PARENT_TBL_INDEX := 1; -- Grouped against single transaction
      ELSE -- No Group Log provided. So, using the counter info to create Transaction
         Begin
            select source_object_code,source_object_id
            into l_src_obj_code,l_src_obj_id
            from CSI_COUNTER_ASSOCIATIONS
            where counter_id = p_ctr_rdg_tbl(l_array_counter).counter_id
            and   rownum < 2;
            --
            l_txn_tbl(l_rdg_count).source_transaction_date := sysdate;
            l_txn_tbl(l_rdg_count).source_header_ref_id := l_src_obj_id;
            IF l_src_obj_code = 'CP' THEN
               l_txn_tbl(l_rdg_count).transaction_type_id := 80;
            ELSIF l_src_obj_code = 'CONTRACT_LINE' THEN
               l_txn_tbl(l_rdg_count).transaction_type_id := 81;
            ELSE
               csi_ctr_gen_utility_pvt.put_line('Unable to get Source Txn Code from Counter Associations..');
	       csi_ctr_gen_utility_pvt.ExitWithErrMsg('CS_API_CTR_SRC_TXN_INFO_REQD');
            END IF;
         Exception
            When no_data_found then
               csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_INVALID');
         End;
         l_ctr_rdg_tbl(l_rdg_count).PARENT_TBL_INDEX := l_rdg_count;
      END IF;
      --
      l_array_counter := p_ctr_rdg_tbl.NEXT(l_array_counter);
   END LOOP;
   --
   IF p_prop_rdg_tbl.count > 0 THEN
      l_array_counter := p_prop_rdg_tbl.First;
      WHILE p_prop_rdg_tbl.EXISTS(l_array_counter) LOOP
         l_prop_rdg_count := l_prop_rdg_count + 1; --Put here for 8441477
	 l_ctr_prop_rdg_tbl(l_prop_rdg_count).parent_tbl_index := NULL;
	 --l_prop_rdg_count := l_prop_rdg_count + 1; --Commented for bug 8441477
	 -- Property should be valid and belong to one of the counters captured above
	 Begin
	    select counter_id
	    into l_counter_id
	    from CSI_COUNTER_PROPERTIES_B
	    where counter_property_id = p_prop_rdg_tbl(l_array_counter).counter_property_id;
	 Exception
	    when no_data_found then
	       csi_ctr_gen_utility_pvt.put_line('Counter Property is Invalid or Expired...');
	       csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_PROP_INVALID');
	 End;
	 --
	 FOR j IN l_ctr_rdg_tbl.FIRST .. l_ctr_rdg_tbl.LAST LOOP
	    IF l_ctr_rdg_tbl(j).counter_id = l_counter_id THEN
	       l_ctr_prop_rdg_tbl(l_prop_rdg_count).parent_tbl_index := j;
	       l_ctr_prop_rdg_tbl(l_prop_rdg_count).VALUE_TIMESTAMP := l_ctr_rdg_tbl(j).VALUE_TIMESTAMP;
	       exit;
	    END IF;
	 END LOOP;
	 --
	 IF l_ctr_prop_rdg_tbl(l_prop_rdg_count).parent_tbl_index IS NULL THEN
	    csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_PROP_INVALID');
	 END IF;
	 --
	 l_ctr_prop_rdg_tbl(l_prop_rdg_count).COUNTER_PROP_VALUE_ID := p_prop_rdg_tbl(l_array_counter).counter_prop_value_id;
	 l_ctr_prop_rdg_tbl(l_prop_rdg_count).COUNTER_PROPERTY_ID := p_prop_rdg_tbl(l_array_counter).counter_property_id;
	 l_ctr_prop_rdg_tbl(l_prop_rdg_count).PROPERTY_VALUE := p_prop_rdg_tbl(l_array_counter).PROPERTY_VALUE ;
	 l_ctr_prop_rdg_tbl(l_prop_rdg_count).ATTRIBUTE1 := p_prop_rdg_tbl(l_array_counter).ATTRIBUTE1;
	 l_ctr_prop_rdg_tbl(l_prop_rdg_count).ATTRIBUTE2 := p_prop_rdg_tbl(l_array_counter).ATTRIBUTE2;
	 l_ctr_prop_rdg_tbl(l_prop_rdg_count).ATTRIBUTE3 := p_prop_rdg_tbl(l_array_counter).ATTRIBUTE3;
	 l_ctr_prop_rdg_tbl(l_prop_rdg_count).ATTRIBUTE4 := p_prop_rdg_tbl(l_array_counter).ATTRIBUTE4;
	 l_ctr_prop_rdg_tbl(l_prop_rdg_count).ATTRIBUTE5 := p_prop_rdg_tbl(l_array_counter).ATTRIBUTE5;
	 l_ctr_prop_rdg_tbl(l_prop_rdg_count).ATTRIBUTE6 := p_prop_rdg_tbl(l_array_counter).ATTRIBUTE6;
	 l_ctr_prop_rdg_tbl(l_prop_rdg_count).ATTRIBUTE7 := p_prop_rdg_tbl(l_array_counter).ATTRIBUTE7;
	 l_ctr_prop_rdg_tbl(l_prop_rdg_count).ATTRIBUTE8 := p_prop_rdg_tbl(l_array_counter).ATTRIBUTE8;
	 l_ctr_prop_rdg_tbl(l_prop_rdg_count).ATTRIBUTE9 := p_prop_rdg_tbl(l_array_counter).ATTRIBUTE9;
	 l_ctr_prop_rdg_tbl(l_prop_rdg_count).ATTRIBUTE10 := p_prop_rdg_tbl(l_array_counter).ATTRIBUTE10;
	 l_ctr_prop_rdg_tbl(l_prop_rdg_count).ATTRIBUTE11 := p_prop_rdg_tbl(l_array_counter).ATTRIBUTE11;
	 l_ctr_prop_rdg_tbl(l_prop_rdg_count).ATTRIBUTE12 := p_prop_rdg_tbl(l_array_counter).ATTRIBUTE12;
	 l_ctr_prop_rdg_tbl(l_prop_rdg_count).ATTRIBUTE13 := p_prop_rdg_tbl(l_array_counter).ATTRIBUTE13;
	 l_ctr_prop_rdg_tbl(l_prop_rdg_count).ATTRIBUTE14 := p_prop_rdg_tbl(l_array_counter).ATTRIBUTE14;
	 l_ctr_prop_rdg_tbl(l_prop_rdg_count).ATTRIBUTE15 := p_prop_rdg_tbl(l_array_counter).ATTRIBUTE15;
	 l_ctr_prop_rdg_tbl(l_prop_rdg_count).ATTRIBUTE_CATEGORY := p_prop_rdg_tbl(l_array_counter).CONTEXT;
	 l_array_counter := p_prop_rdg_tbl.NEXT(l_array_counter);
      END LOOP;
   END IF;
   --
   -- Call CSI Capture Counter Reading API
   Csi_Counter_Readings_Pub.Capture_Counter_Reading
   (
       p_api_version           =>   1.0
      ,p_commit                =>   p_commit
      ,p_init_msg_list         =>   p_init_msg_list
      ,p_validation_level      =>   p_validation_level
      ,p_txn_tbl               =>   l_txn_tbl
      ,p_ctr_rdg_tbl           =>   l_ctr_rdg_tbl
      ,p_ctr_prop_rdg_tbl      =>   l_ctr_prop_rdg_tbl
      ,x_return_status         =>   x_return_status
      ,x_msg_count             =>   x_msg_count
      ,x_msg_data              =>   x_msg_data
   );
   --
   IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      csi_ctr_gen_utility_pvt.put_line('ERROR FROM Capture_Counter_Reading_pub API ');
      l_msg_index := 1;
      l_msg_count := x_msg_count;
      WHILE l_msg_count > 0 LOOP
	 x_msg_data := FND_MSG_PUB.GET
	 (  l_msg_index,
	    FND_API.G_FALSE
	 );
	 csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
	 l_msg_index := l_msg_index + 1;
	 l_msg_count := l_msg_count - 1;
      END LOOP;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   --
   -- End of API body
   --
   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
       COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (  p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO CS_CTR_CAPTURE_READING_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count ,
             p_data => x_msg_data
            );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CS_CTR_CAPTURE_READING_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
             (p_count => x_msg_count ,
              p_data => x_msg_data
             );
   WHEN OTHERS THEN
      ROLLBACK TO CS_CTR_CAPTURE_READING_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count ,
             p_data => x_msg_data
            );
END Capture_Counter_Reading;

PROCEDURE Update_Counter_Reading(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_CTR_GRP_LOG_ID             IN   NUMBER,
    p_CTR_RDG_Tbl                IN   CTR_RDG_Tbl_Type,
    p_PROP_RDG_Tbl               IN   PROP_RDG_Tbl_Type,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
 )
IS
   l_api_name                CONSTANT VARCHAR2(30) := 'UPDATE_COUNTER_READING';
   l_api_version_number      CONSTANT NUMBER   := 1.0;
   l_return_status_full      VARCHAR2(1);
   l_s_temp                  VARCHAR2(100);
   l_ctr_grp_log_id          NUMBER;
   l_array_counter           NUMBER;
   l_ctr_rdg_tbl             csi_ctr_datastructures_pub.counter_readings_tbl;
   --
   l_rdg_count               NUMBER := 0;
   l_msg_index               NUMBER;
   l_msg_count               NUMBER;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT CS_CTR_CAPTURE_READING_PUB;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
					p_api_version_number,
					l_api_name,
					G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --
   -- API body
   --
   IF p_ctr_rdg_tbl.count > 0 THEN
      l_array_counter := p_ctr_rdg_tbl.First;
      WHILE p_ctr_rdg_tbl.EXISTS(l_array_counter) LOOP
	 l_rdg_count := l_rdg_count + 1;
	 l_ctr_rdg_tbl(l_rdg_count).COUNTER_VALUE_ID := p_ctr_rdg_tbl(l_array_counter).counter_value_id;
	 l_ctr_rdg_tbl(l_rdg_count).COUNTER_ID := p_ctr_rdg_tbl(l_array_counter).counter_id;
	 l_ctr_rdg_tbl(l_rdg_count).VALUE_TIMESTAMP  := p_ctr_rdg_tbl(l_array_counter).VALUE_TIMESTAMP;
	 l_ctr_rdg_tbl(l_rdg_count).COUNTER_READING := p_ctr_rdg_tbl(l_array_counter).COUNTER_READING ;
	 --
	 IF NVL(p_ctr_rdg_tbl(l_array_counter).RESET_FLAG,'N') = 'Y' THEN
	    l_ctr_rdg_tbl(l_rdg_count).RESET_MODE  := 'SOFT';
	 ELSE
	    l_ctr_rdg_tbl(l_rdg_count).RESET_MODE  := NULL;
	 END IF;
	 --
	 l_ctr_rdg_tbl(l_rdg_count).RESET_REASON  := p_ctr_rdg_tbl(l_array_counter).RESET_REASON;
	 l_ctr_rdg_tbl(l_rdg_count).COUNTER_READING  := p_ctr_rdg_tbl(l_array_counter).PRE_RESET_LAST_RDG;
	 l_ctr_rdg_tbl(l_rdg_count).RESET_COUNTER_READING :=p_ctr_rdg_tbl(l_array_counter).POST_RESET_FIRST_RDG;
	 l_ctr_rdg_tbl(l_rdg_count).ADJUSTMENT_TYPE  := p_ctr_rdg_tbl(l_array_counter).MISC_READING_TYPE;
	 l_ctr_rdg_tbl(l_rdg_count).ADJUSTMENT_READING   := p_ctr_rdg_tbl(l_array_counter).MISC_READING ;
	 l_ctr_rdg_tbl(l_rdg_count).ATTRIBUTE1 := p_ctr_rdg_tbl(l_array_counter).ATTRIBUTE1;
	 l_ctr_rdg_tbl(l_rdg_count).ATTRIBUTE2 := p_ctr_rdg_tbl(l_array_counter).ATTRIBUTE2;
	 l_ctr_rdg_tbl(l_rdg_count).ATTRIBUTE3 := p_ctr_rdg_tbl(l_array_counter).ATTRIBUTE3;
	 l_ctr_rdg_tbl(l_rdg_count).ATTRIBUTE4 := p_ctr_rdg_tbl(l_array_counter).ATTRIBUTE4;
	 l_ctr_rdg_tbl(l_rdg_count).ATTRIBUTE5 := p_ctr_rdg_tbl(l_array_counter).ATTRIBUTE5;
	 l_ctr_rdg_tbl(l_rdg_count).ATTRIBUTE6 := p_ctr_rdg_tbl(l_array_counter).ATTRIBUTE6;
	 l_ctr_rdg_tbl(l_rdg_count).ATTRIBUTE7 := p_ctr_rdg_tbl(l_array_counter).ATTRIBUTE7;
	 l_ctr_rdg_tbl(l_rdg_count).ATTRIBUTE8 := p_ctr_rdg_tbl(l_array_counter).ATTRIBUTE8;
	 l_ctr_rdg_tbl(l_rdg_count).ATTRIBUTE9 := p_ctr_rdg_tbl(l_array_counter).ATTRIBUTE9;
	 l_ctr_rdg_tbl(l_rdg_count).ATTRIBUTE10 := p_ctr_rdg_tbl(l_array_counter).ATTRIBUTE10;
	 l_ctr_rdg_tbl(l_rdg_count).ATTRIBUTE11 := p_ctr_rdg_tbl(l_array_counter).ATTRIBUTE11;
	 l_ctr_rdg_tbl(l_rdg_count).ATTRIBUTE12 := p_ctr_rdg_tbl(l_array_counter).ATTRIBUTE12;
	 l_ctr_rdg_tbl(l_rdg_count).ATTRIBUTE13 := p_ctr_rdg_tbl(l_array_counter).ATTRIBUTE13;
	 l_ctr_rdg_tbl(l_rdg_count).ATTRIBUTE14 := p_ctr_rdg_tbl(l_array_counter).ATTRIBUTE14;
	 l_ctr_rdg_tbl(l_rdg_count).ATTRIBUTE15 := p_ctr_rdg_tbl(l_array_counter).ATTRIBUTE15;
	 l_ctr_rdg_tbl(l_rdg_count).ATTRIBUTE_CATEGORY := p_ctr_rdg_tbl(l_array_counter).CONTEXT;
	 l_ctr_rdg_tbl(l_rdg_count).COMMENTS     := p_ctr_rdg_tbl(l_array_counter).COMMENTS;
	 l_ctr_rdg_tbl(l_rdg_count).DISABLED_FLAG := p_ctr_rdg_tbl(l_array_counter).OVERRIDE_VALID_FLAG;
	 --
	 l_array_counter := p_ctr_rdg_tbl.NEXT(l_array_counter);
      END LOOP;
      --
      -- Call CSI Update Counter Reading API
      Csi_Counter_Readings_Pub.Update_Counter_Reading
      (
	  p_api_version           =>   1.0
	 ,p_commit                =>   p_commit
	 ,p_init_msg_list         =>   p_init_msg_list
	 ,p_validation_level      =>   p_validation_level
	 ,p_ctr_rdg_tbl           =>   l_ctr_rdg_tbl
	 ,x_return_status         =>   x_return_status
	 ,x_msg_count             =>   x_msg_count
	 ,x_msg_data              =>   x_msg_data
      );
      --
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	 csi_ctr_gen_utility_pvt.put_line('ERROR FROM Update_Counter_Reading_pub API ');
	 l_msg_index := 1;
	 l_msg_count := x_msg_count;
	 WHILE l_msg_count > 0 LOOP
	    x_msg_data := FND_MSG_PUB.GET
	    (  l_msg_index,
	       FND_API.G_FALSE
	    );
	    csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
	    l_msg_index := l_msg_index + 1;
	    l_msg_count := l_msg_count - 1;
	 END LOOP;
	 RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   --
   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
       COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (  p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO CS_CTR_CAPTURE_READING_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count ,
             p_data => x_msg_data
            );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CS_CTR_CAPTURE_READING_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
             (p_count => x_msg_count ,
              p_data => x_msg_data
             );
   WHEN OTHERS THEN
      ROLLBACK TO CS_CTR_CAPTURE_READING_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count ,
             p_data => x_msg_data
            );
END Update_Counter_Reading;

PROCEDURE CAPTURE_COUNTER_READING(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_CTR_RDG_Rec                IN   CTR_RDG_Rec_Type,
    p_COUNTER_GRP_LOG_ID         IN   NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
   ) IS
   l_api_name                CONSTANT   VARCHAR2(30)   := 'CAPTURE_COUNTER_READING';
   l_api_version_number      CONSTANT   NUMBER         := 1.0;
   l_txn_tbl                 csi_datastructures_pub.transaction_tbl;
   l_ctr_rdg_tbl             csi_ctr_datastructures_pub.counter_readings_tbl;
   l_ctr_prop_rdg_tbl        csi_ctr_datastructures_pub.ctr_property_readings_tbl;
   l_src_obj_code            CSI_COUNTER_ASSOCIATIONS.source_object_code%TYPE;
   l_src_obj_id              NUMBER;
   --
   l_rdg_count               NUMBER := 0;
   l_msg_index               NUMBER;
   l_msg_count               NUMBER;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT CS_CTR_CAPTURE_READING_PUB;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
					p_api_version_number,
					l_api_name,
					G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --
   IF p_counter_grp_log_id IS NULL THEN
      Begin
	 select source_object_code,source_object_id
	 into l_src_obj_code,l_src_obj_id
	 from CSI_COUNTER_ASSOCIATIONS
	 where counter_id = p_ctr_rdg_rec.counter_id
	 and   rownum < 2;
	 --
	 l_txn_tbl(1).source_transaction_date := sysdate;
	 l_txn_tbl(1).source_header_ref_id := l_src_obj_id;
	 IF l_src_obj_code = 'CP' THEN
	    l_txn_tbl(1).transaction_type_id := 80;
	 ELSIF l_src_obj_code = 'CONTRACT_LINE' THEN
	    l_txn_tbl(1).transaction_type_id := 81;
	 ELSE
	    csi_ctr_gen_utility_pvt.put_line('Unable to get Source Txn Code from Counter Associations..');
	    csi_ctr_gen_utility_pvt.ExitWithErrMsg('CS_API_CTR_SRC_TXN_INFO_REQD');
	 END IF;
      Exception
         When no_data_found then
	    csi_ctr_gen_utility_pvt.ExitWithErrMsg('CSI_API_CTR_INVALID');
      End;
   ELSE -- Should have got inserted into CSI Transaction during Pre Capture Phase
      Begin
         select transaction_type_id,source_header_ref_id,source_transaction_date
         into l_txn_tbl(1).transaction_type_id,
              l_txn_tbl(1).source_header_ref_id,
              l_txn_tbl(1).source_transaction_date
         from CSI_TRANSACTIONS
         where transaction_id = p_counter_grp_log_id;
      Exception
         when no_data_found then
            csi_ctr_gen_utility_pvt.put_line('Counter Group Log passed did not get into CSI_TRANSACTIONS..');
	    csi_ctr_gen_utility_pvt.ExitWithErrMsg
	       ( p_msg_name    =>  'CSI_INVALID_TXN_ID',
	         p_token1_name =>  'transaction_id',
	         p_token1_val  =>  to_char(p_counter_grp_log_id)
	       );
      End;
   END IF;
   --
   l_ctr_rdg_tbl(1).COUNTER_VALUE_ID := p_ctr_rdg_rec.counter_value_id;
   l_ctr_rdg_tbl(1).COUNTER_ID := p_ctr_rdg_rec.counter_id;
   l_ctr_rdg_tbl(1).VALUE_TIMESTAMP  := p_ctr_rdg_rec.VALUE_TIMESTAMP;
   l_ctr_rdg_tbl(1).COUNTER_READING := p_ctr_rdg_rec.COUNTER_READING ;
   --
   IF NVL(p_ctr_rdg_rec.RESET_FLAG,'N') = 'Y' THEN
      l_ctr_rdg_tbl(1).RESET_MODE  := 'SOFT';
   ELSE
      l_ctr_rdg_tbl(1).RESET_MODE  := NULL;
   END IF;
   --
   l_ctr_rdg_tbl(1).RESET_REASON  := p_ctr_rdg_rec.RESET_REASON;
   l_ctr_rdg_tbl(1).COUNTER_READING  := p_ctr_rdg_rec.PRE_RESET_LAST_RDG;
   l_ctr_rdg_tbl(1).RESET_COUNTER_READING :=p_ctr_rdg_rec.POST_RESET_FIRST_RDG;
   l_ctr_rdg_tbl(1).ADJUSTMENT_TYPE  := p_ctr_rdg_rec.MISC_READING_TYPE;
   l_ctr_rdg_tbl(1).ADJUSTMENT_READING   := p_ctr_rdg_rec.MISC_READING ;
   l_ctr_rdg_tbl(1).ATTRIBUTE1 := p_ctr_rdg_rec.ATTRIBUTE1;
   l_ctr_rdg_tbl(1).ATTRIBUTE2 := p_ctr_rdg_rec.ATTRIBUTE2;
   l_ctr_rdg_tbl(1).ATTRIBUTE3 := p_ctr_rdg_rec.ATTRIBUTE3;
   l_ctr_rdg_tbl(1).ATTRIBUTE4 := p_ctr_rdg_rec.ATTRIBUTE4;
   l_ctr_rdg_tbl(1).ATTRIBUTE5 := p_ctr_rdg_rec.ATTRIBUTE5;
   l_ctr_rdg_tbl(1).ATTRIBUTE6 := p_ctr_rdg_rec.ATTRIBUTE6;
   l_ctr_rdg_tbl(1).ATTRIBUTE7 := p_ctr_rdg_rec.ATTRIBUTE7;
   l_ctr_rdg_tbl(1).ATTRIBUTE8 := p_ctr_rdg_rec.ATTRIBUTE8;
   l_ctr_rdg_tbl(1).ATTRIBUTE9 := p_ctr_rdg_rec.ATTRIBUTE9;
   l_ctr_rdg_tbl(1).ATTRIBUTE10 := p_ctr_rdg_rec.ATTRIBUTE10;
   l_ctr_rdg_tbl(1).ATTRIBUTE11 := p_ctr_rdg_rec.ATTRIBUTE11;
   l_ctr_rdg_tbl(1).ATTRIBUTE12 := p_ctr_rdg_rec.ATTRIBUTE12;
   l_ctr_rdg_tbl(1).ATTRIBUTE13 := p_ctr_rdg_rec.ATTRIBUTE13;
   l_ctr_rdg_tbl(1).ATTRIBUTE14 := p_ctr_rdg_rec.ATTRIBUTE14;
   l_ctr_rdg_tbl(1).ATTRIBUTE15 := p_ctr_rdg_rec.ATTRIBUTE15;
   l_ctr_rdg_tbl(1).ATTRIBUTE_CATEGORY := p_ctr_rdg_rec.CONTEXT;
   l_ctr_rdg_tbl(1).COMMENTS     := p_ctr_rdg_rec.COMMENTS;
   l_ctr_rdg_tbl(1).DISABLED_FLAG := p_ctr_rdg_rec.OVERRIDE_VALID_FLAG;
   l_ctr_rdg_tbl(1).PARENT_TBL_INDEX := 1; -- Grouped against single transaction
   --
   -- Call CSI Capture Counter Reading API
   Csi_Counter_Readings_Pub.Capture_Counter_Reading
   (
       p_api_version           =>   1.0
      ,p_commit                =>   p_commit
      ,p_init_msg_list         =>   p_init_msg_list
      ,p_validation_level      =>   p_validation_level
      ,p_txn_tbl               =>   l_txn_tbl
      ,p_ctr_rdg_tbl           =>   l_ctr_rdg_tbl
      ,p_ctr_prop_rdg_tbl      =>   l_ctr_prop_rdg_tbl
      ,x_return_status         =>   x_return_status
      ,x_msg_count             =>   x_msg_count
      ,x_msg_data              =>   x_msg_data
   );
   --
   IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      csi_ctr_gen_utility_pvt.put_line('ERROR FROM Capture_Counter_Reading_pub API ');
      l_msg_index := 1;
      l_msg_count := x_msg_count;
      WHILE l_msg_count > 0 LOOP
	 x_msg_data := FND_MSG_PUB.GET
	 (  l_msg_index,
	    FND_API.G_FALSE
	 );
	 csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
	 l_msg_index := l_msg_index + 1;
	 l_msg_count := l_msg_count - 1;
      END LOOP;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   --
   -- End of API body
   --
   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
       COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (  p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO CS_CTR_CAPTURE_READING_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count ,
             p_data => x_msg_data
            );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CS_CTR_CAPTURE_READING_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
             (p_count => x_msg_count ,
              p_data => x_msg_data
             );
   WHEN OTHERS THEN
      ROLLBACK TO CS_CTR_CAPTURE_READING_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count ,
             p_data => x_msg_data
            );
END Capture_Counter_Reading;

PROCEDURE Update_Counter_Reading(
    p_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_CTR_RDG_Rec                IN   CTR_RDG_Rec_Type,
    p_COUNTER_GRP_LOG_ID         IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
   ) IS
   --
   l_api_name                CONSTANT   VARCHAR2(30)   := 'UPDATE_COUNTER_READING';
   l_api_version_number      CONSTANT   NUMBER         := 1.0;
   l_ctr_rdg_tbl             csi_ctr_datastructures_pub.counter_readings_tbl;
   l_msg_index               NUMBER;
   l_msg_count               NUMBER;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT CS_CTR_CAPTURE_READING_PUB;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
					p_api_version_number,
					l_api_name,
					G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --
   -- API body
   --
   l_ctr_rdg_tbl(1).COUNTER_VALUE_ID := p_ctr_rdg_rec.counter_value_id;
   l_ctr_rdg_tbl(1).COUNTER_ID := p_ctr_rdg_rec.counter_id;
   l_ctr_rdg_tbl(1).VALUE_TIMESTAMP  := p_ctr_rdg_rec.VALUE_TIMESTAMP;
   l_ctr_rdg_tbl(1).COUNTER_READING := p_ctr_rdg_rec.COUNTER_READING ;
   --
   IF NVL(p_ctr_rdg_rec.RESET_FLAG,'N') = 'Y' THEN
      l_ctr_rdg_tbl(1).RESET_MODE  := 'SOFT';
   ELSE
      l_ctr_rdg_tbl(1).RESET_MODE  := NULL;
   END IF;
   --
   l_ctr_rdg_tbl(1).RESET_REASON  := p_ctr_rdg_rec.RESET_REASON;
   l_ctr_rdg_tbl(1).COUNTER_READING  := p_ctr_rdg_rec.PRE_RESET_LAST_RDG;
   l_ctr_rdg_tbl(1).RESET_COUNTER_READING :=p_ctr_rdg_rec.POST_RESET_FIRST_RDG;
   l_ctr_rdg_tbl(1).ADJUSTMENT_TYPE  := p_ctr_rdg_rec.MISC_READING_TYPE;
   l_ctr_rdg_tbl(1).ADJUSTMENT_READING   := p_ctr_rdg_rec.MISC_READING ;
   l_ctr_rdg_tbl(1).ATTRIBUTE1 := p_ctr_rdg_rec.ATTRIBUTE1;
   l_ctr_rdg_tbl(1).ATTRIBUTE2 := p_ctr_rdg_rec.ATTRIBUTE2;
   l_ctr_rdg_tbl(1).ATTRIBUTE3 := p_ctr_rdg_rec.ATTRIBUTE3;
   l_ctr_rdg_tbl(1).ATTRIBUTE4 := p_ctr_rdg_rec.ATTRIBUTE4;
   l_ctr_rdg_tbl(1).ATTRIBUTE5 := p_ctr_rdg_rec.ATTRIBUTE5;
   l_ctr_rdg_tbl(1).ATTRIBUTE6 := p_ctr_rdg_rec.ATTRIBUTE6;
   l_ctr_rdg_tbl(1).ATTRIBUTE7 := p_ctr_rdg_rec.ATTRIBUTE7;
   l_ctr_rdg_tbl(1).ATTRIBUTE8 := p_ctr_rdg_rec.ATTRIBUTE8;
   l_ctr_rdg_tbl(1).ATTRIBUTE9 := p_ctr_rdg_rec.ATTRIBUTE9;
   l_ctr_rdg_tbl(1).ATTRIBUTE10 := p_ctr_rdg_rec.ATTRIBUTE10;
   l_ctr_rdg_tbl(1).ATTRIBUTE11 := p_ctr_rdg_rec.ATTRIBUTE11;
   l_ctr_rdg_tbl(1).ATTRIBUTE12 := p_ctr_rdg_rec.ATTRIBUTE12;
   l_ctr_rdg_tbl(1).ATTRIBUTE13 := p_ctr_rdg_rec.ATTRIBUTE13;
   l_ctr_rdg_tbl(1).ATTRIBUTE14 := p_ctr_rdg_rec.ATTRIBUTE14;
   l_ctr_rdg_tbl(1).ATTRIBUTE15 := p_ctr_rdg_rec.ATTRIBUTE15;
   l_ctr_rdg_tbl(1).ATTRIBUTE_CATEGORY := p_ctr_rdg_rec.CONTEXT;
   l_ctr_rdg_tbl(1).COMMENTS     := p_ctr_rdg_rec.COMMENTS;
   l_ctr_rdg_tbl(1).DISABLED_FLAG := p_ctr_rdg_rec.OVERRIDE_VALID_FLAG;
   --
   -- Call CSI Update Counter Reading API
   Csi_Counter_Readings_Pub.Update_Counter_Reading
   (
       p_api_version           =>   1.0
      ,p_commit                =>   p_commit
      ,p_init_msg_list         =>   p_init_msg_list
      ,p_validation_level      =>   p_validation_level
      ,p_ctr_rdg_tbl           =>   l_ctr_rdg_tbl
      ,x_return_status         =>   x_return_status
      ,x_msg_count             =>   x_msg_count
      ,x_msg_data              =>   x_msg_data
   );
   --
   IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      csi_ctr_gen_utility_pvt.put_line('ERROR FROM Update_Counter_Reading_pub API ');
      l_msg_index := 1;
      l_msg_count := x_msg_count;
      WHILE l_msg_count > 0 LOOP
	 x_msg_data := FND_MSG_PUB.GET
	 (  l_msg_index,
	    FND_API.G_FALSE
	 );
	 csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
	 l_msg_index := l_msg_index + 1;
	 l_msg_count := l_msg_count - 1;
      END LOOP;
      RAISE FND_API.G_EXC_ERROR;
      END IF;
   --
   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
       COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (  p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO CS_CTR_CAPTURE_READING_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count ,
             p_data => x_msg_data
            );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CS_CTR_CAPTURE_READING_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
             (p_count => x_msg_count ,
              p_data => x_msg_data
             );
   WHEN OTHERS THEN
      ROLLBACK TO CS_CTR_CAPTURE_READING_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count ,
             p_data => x_msg_data
            );
END Update_Counter_Reading;


 PROCEDURE Capture_Ctr_Prop_Reading(
     p_Api_version_number      IN   NUMBER,
     p_Init_Msg_List           IN   VARCHAR2,
     P_Commit                  IN   VARCHAR2,
     p_validation_level        IN   NUMBER,
     p_PROP_RDG_Rec            IN   PROP_RDG_Rec_Type,
     p_COUNTER_GRP_LOG_ID      IN   NUMBER,
     X_Return_Status           OUT  NOCOPY VARCHAR2,
     X_Msg_Count               OUT  NOCOPY NUMBER,
     X_Msg_Data                OUT  NOCOPY VARCHAR2
     ) IS
         l_api_name            CONSTANT VARCHAR2(30)  := 'CAPTURE_CTR_PROP_READING';
         l_api_version_number  CONSTANT NUMBER        := 1.0;
 BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
 END Capture_CTR_Prop_Reading;

PROCEDURE PRE_CAPTURE_CTR_READING(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    P_CTR_GRP_LOG_Rec            IN   CTR_GRP_LOG_Rec_Type,
    X_COUNTER_GRP_LOG_ID         IN OUT  NOCOPY NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    ) IS
   --
   l_api_name                CONSTANT VARCHAR2(30) := 'PRE_CAPTURE_COUNTER_READING';
   l_api_version_number      CONSTANT NUMBER   := 1.0;
   l_txn_rec                 csi_datastructures_pub.transaction_rec;
   l_msg_data                VARCHAR2(2000);
   l_msg_index               NUMBER;
   l_msg_count               NUMBER;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT PRE_CAPTURE_READING_PUB;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
					p_api_version_number,
					l_api_name,
					G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --
   csi_ctr_gen_utility_pvt.put_line('Inside PRE_CAPTURE_COUNTER_READING...');
   csi_ctr_gen_utility_pvt.put_line('Source Transaction Code : '||p_ctr_grp_log_rec.source_transaction_code);
   csi_ctr_gen_utility_pvt.put_line('Source Transaction ID : '||to_char(p_ctr_grp_log_rec.source_transaction_id));
   --
   IF NVL(p_ctr_grp_log_rec.source_transaction_code,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
      IF p_ctr_grp_log_rec.source_transaction_code in ('CP','INTERNAL') THEN
	 l_txn_rec.transaction_type_id := 80;
      ELSIF p_ctr_grp_log_rec.source_transaction_code = 'CONTRACT_LINE' THEN
	 l_txn_rec.transaction_type_id := 81;
      ELSIF p_ctr_grp_log_rec.source_transaction_code = 'OKL_CNTR_GRP' THEN
	 l_txn_rec.transaction_type_id := 85;
      ELSIF p_ctr_grp_log_rec.source_transaction_code = 'FS' THEN
         l_txn_rec.transaction_type_id := 86;
      ELSIF p_ctr_grp_log_rec.source_transaction_code = 'DR' THEN
         l_txn_rec.transaction_type_id := 87;
      ELSE
	 csi_ctr_gen_utility_pvt.put_line('Invalid Source Transaction Code : '||p_ctr_grp_log_rec.source_transaction_code);
	 csi_ctr_gen_utility_pvt.ExitWithErrMsg('CS_API_CTR_SRC_TXN_INFO_REQD');
      END IF;
      --
      l_txn_rec.source_header_ref_id := p_ctr_grp_log_rec.source_transaction_id;
      l_txn_rec.source_transaction_date := sysdate;
      l_txn_rec.ATTRIBUTE1 := p_CTR_GRP_LOG_Rec.ATTRIBUTE1;
      l_txn_rec.ATTRIBUTE2 := p_CTR_GRP_LOG_Rec.ATTRIBUTE2;
      l_txn_rec.ATTRIBUTE3 := p_CTR_GRP_LOG_Rec.ATTRIBUTE3;
      l_txn_rec.ATTRIBUTE4 := p_CTR_GRP_LOG_Rec.ATTRIBUTE4;
      l_txn_rec.ATTRIBUTE5 := p_CTR_GRP_LOG_Rec.ATTRIBUTE5;
      l_txn_rec.ATTRIBUTE6 := p_CTR_GRP_LOG_Rec.ATTRIBUTE6;
      l_txn_rec.ATTRIBUTE7 := p_CTR_GRP_LOG_Rec.ATTRIBUTE7;
      l_txn_rec.ATTRIBUTE8 := p_CTR_GRP_LOG_Rec.ATTRIBUTE8;
      l_txn_rec.ATTRIBUTE9 := p_CTR_GRP_LOG_Rec.ATTRIBUTE9;
      l_txn_rec.ATTRIBUTE10 := p_CTR_GRP_LOG_Rec.ATTRIBUTE10;
      l_txn_rec.ATTRIBUTE11 := p_CTR_GRP_LOG_Rec.ATTRIBUTE11;
      l_txn_rec.ATTRIBUTE12 := p_CTR_GRP_LOG_Rec.ATTRIBUTE12;
      l_txn_rec.ATTRIBUTE13 := p_CTR_GRP_LOG_Rec.ATTRIBUTE13;
      l_txn_rec.ATTRIBUTE14 := p_CTR_GRP_LOG_Rec.ATTRIBUTE14;
      l_txn_rec.ATTRIBUTE15 := p_CTR_GRP_LOG_Rec.ATTRIBUTE15;
      l_txn_rec.CONTEXT := p_CTR_GRP_LOG_Rec.CONTEXT;
      --
      -- Call Create_Reading Transaction to insert into CSI_TRANSACTIONS
      csi_ctr_gen_utility_pvt.put_line('Calling Create_Reading_Transaction...');
      Csi_Counter_Readings_Pvt.Create_Reading_Transaction
	 ( p_api_version           =>  1.0
	  ,p_commit                =>  fnd_api.g_false
	  ,p_init_msg_list         =>  fnd_api.g_true
	  ,p_validation_level      =>  fnd_api.g_valid_level_full
	  ,p_txn_rec               =>  l_txn_rec
	  ,x_return_status         =>  x_return_status
	  ,x_msg_count             =>  x_msg_count
	  ,x_msg_data              =>  x_msg_data
	 );
      IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	 csi_ctr_gen_utility_pvt.put_line('Error from Create_Reading_Transaction...');
	 l_msg_index := 1;
	 FND_MSG_PUB.Count_And_Get
	      (p_count  =>  x_msg_count,
	       p_data   =>  x_msg_data
	      );
	 l_msg_count := x_msg_count;
	 WHILE l_msg_count > 0 LOOP
	       x_msg_data := FND_MSG_PUB.GET
		    (  l_msg_index,
		       FND_API.G_FALSE        );
		csi_ctr_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
		l_msg_index := l_msg_index + 1;
		l_msg_count := l_msg_count - 1;
	 END LOOP;
	 RAISE FND_API.G_EXC_ERROR;
      ELSE -- Transaction created successfully
         X_COUNTER_GRP_LOG_ID := l_txn_rec.transaction_id;
      END IF;
   ELSE
      X_COUNTER_GRP_LOG_ID := NULL;
   END IF;
   --
   -- End of API body
   --
   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
       COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (  p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO PRE_CAPTURE_READING_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count ,
             p_data => x_msg_data
            );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO PRE_CAPTURE_READING_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
             (p_count => x_msg_count ,
              p_data => x_msg_data
             );
   WHEN OTHERS THEN
      ROLLBACK TO PRE_CAPTURE_READING_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count ,
             p_data => x_msg_data
            );
END PRE_CAPTURE_CTR_READING;
--
PROCEDURE POST_CAPTURE_CTR_READING(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_COUNTER_GRP_LOG_ID         IN   NUMBER,
    P_READING_UPDATED            IN   VARCHAR2,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    ) IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
END POST_CAPTURE_CTR_READING;
--
PROCEDURE UPDATE_CTR_PROP_READING(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2,
    p_commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_PROP_RDG_Rec               IN   PROP_RDG_Rec_Type,
    p_COUNTER_GRP_LOG_ID         IN   NUMBER,
    p_object_version_number      IN   NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    ) IS
     l_api_name            CONSTANT  VARCHAR2(30)  := 'UPDATE_CTR_PROP_READING';
     l_api_version_number  CONSTANT  NUMBER  := 1.0;
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
END Update_CTR_Prop_Reading;
END CS_CTR_CAPTURE_READING_PUB;

/
