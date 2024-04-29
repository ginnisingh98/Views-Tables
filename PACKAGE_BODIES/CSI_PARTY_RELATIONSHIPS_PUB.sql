--------------------------------------------------------
--  DDL for Package Body CSI_PARTY_RELATIONSHIPS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_PARTY_RELATIONSHIPS_PUB" AS
/* $Header: csipipb.pls 120.8.12010000.2 2009/03/06 21:22:50 hyonlee ship $ */

g_pkg_name  CONSTANT VARCHAR2(30) := 'CSI_PARTY_RELATIONSHIPS_PUB';

/*------------------------------------------------------------*/
/* Procedure name:  Get_inst_party_relationships              */
/* Description :   Procedure used to  get party relationships */
/*                                 for an item instance       */
/*------------------------------------------------------------*/

PROCEDURE get_inst_party_relationships
 (    p_api_version             IN  NUMBER
     ,p_commit                  IN  VARCHAR2
     ,p_init_msg_list           IN  VARCHAR2
     ,p_validation_level        IN  NUMBER
     ,p_party_query_rec         IN  csi_datastructures_pub.party_query_rec
     ,p_resolve_id_columns      IN  VARCHAR2
     ,p_time_stamp              IN  DATE
     ,x_party_header_tbl        OUT NOCOPY csi_datastructures_pub.party_header_tbl
     ,x_return_status           OUT NOCOPY VARCHAR2
     ,x_msg_count               OUT NOCOPY NUMBER
     ,x_msg_data                OUT NOCOPY VARCHAR2
    ) IS

     l_api_name      CONSTANT VARCHAR2(30)   := 'GET_INST_PARTY_RELATIONSHIP' ;
     l_api_version   CONSTANT NUMBER         := 1.0                           ;
     l_csi_debug_level        NUMBER                                          ;
     l_instance_party_id      NUMBER                                          ;
     l_contact_party_id       NUMBER                                          ;
     l_contact_flag           VARCHAR2(1);
     l_party_source_tbl       VARCHAR2(30)                                    ;
     l_contact_details        csi_datastructures_pub.contact_details_rec ;
     l_count                  NUMBER         := 0                             ;
     l_where_clause           VARCHAR2(2000) := ''                            ;
     l_get_party_cursor_id    NUMBER                                          ;
     l_party_rec              csi_datastructures_pub.party_header_rec         ;
     l_flag                   VARCHAR2(1)  :='N'                              ;
     l_rows_processed         NUMBER                                          ;
	 l_pty_lookup_type        VARCHAR2(30) := 'CSI_PARTY_SOURCE_TABLE'        ;
     l_select_stmt            VARCHAR2(20000) := ' SELECT instance_party_id, instance_id, party_source_table, '||
                                 ' party_id, relationship_type_code,contact_flag ,contact_ip_id, active_start_date, '||
                                 ' active_end_date, context,attribute1,attribute2,attribute3, attribute4,attribute5, '||
                                 ' attribute6, attribute7, attribute8, attribute9, attribute10 ,attribute11, '||
                                 ' attribute12,attribute13,attribute14,attribute15 ,object_version_number, '||
                                 ' primary_flag, preferred_flag'||
                                 ' FROM CSI_I_PARTIES  ';
    l_pty_name                VARCHAR2(360);

BEGIN
        -- Standard Start of API savepoint
       -- SAVEPOINT   get_inst_party_rel_pub;

     -- Check for freeze_flag in csi_install_parameters is set to 'Y'

     csi_utility_grp.check_ib_active;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (    l_api_version           ,
                                                p_api_version           ,
                                                l_api_name              ,
                                                g_pkg_name              )
        THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- Check the profile option CSI_DEBUG_LEVEL for debug message reporting
        l_csi_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

        -- If CSI_DEBUG_LEVEL = 1 then dump the procedure name
        IF (l_csi_debug_level > 0) THEN
            csi_gen_utility_pvt.put_line( 'get_inst_party_relationship');
        END IF;

        -- If the debug level = 2 then dump all the parameters values.
        IF (l_csi_debug_level > 1) THEN
            csi_gen_utility_pvt.put_line(  'get_inst_party_relationship'   ||
                                                 p_api_version           ||'-'||
                                                 p_commit                ||'-'||
                                                 p_init_msg_list         ||'-'||
                                                 p_validation_level      ||'-'||
                                                 p_time_stamp                  );
             -- dump the in parameter in the log file
             csi_gen_utility_pvt.dump_party_query_rec(p_party_query_rec) ;
        END IF;

        /***** srramakr commented for bug # 3304439
        -- Check for the profile option and enable trace
        l_flag:=csi_gen_utility_pvt.enable_trace(l_trace_flag => l_flag);
        -- End enable trace
        ****/

        -- Start API body
        -- check if atleast one query parameters are passed else
        -- raise an error
        IF     (p_party_query_rec.instance_party_id  = FND_API.G_MISS_NUM)
          AND  (p_party_query_rec.instance_id        = FND_API.G_MISS_NUM)
          AND  (p_party_query_rec.party_id           = FND_API.G_MISS_NUM)
          AND  (p_party_query_rec.relationship_type_code = FND_API.G_MISS_CHAR) THEN

           FND_MESSAGE.Set_Name('CSI', 'CSI_API_INVALID_PARAMETERS');
           FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

       -- Generate the where clause dynamically
       csi_party_relationships_pvt.Gen_Pty_Where_Clause
       (   p_party_query_rec      =>  p_party_query_rec,
           x_where_clause         =>  l_where_clause    );

       -- Build the select statement
       l_select_stmt := l_select_stmt || ' where '||l_where_clause;

       -- Open the cursor
       l_get_party_cursor_id := dbms_sql.open_cursor;

       --Parse the select statement
       dbms_sql.parse(l_get_party_cursor_id, l_select_stmt , dbms_sql.native);

       -- Bind the variables
       csi_party_relationships_pvt.Bind_pty_variable(p_party_query_rec, l_get_party_cursor_id);

       -- Define output variables
       csi_party_relationships_pvt.Define_Pty_Columns(l_get_party_cursor_id);

        -- execute the select statement
       l_rows_processed := dbms_sql.execute(l_get_party_cursor_id);

       LOOP
       EXIT WHEN DBMS_SQL.FETCH_ROWS(l_get_party_cursor_id) = 0;
             -- get the values after executing the selecl statement
             csi_party_relationships_pvt.Get_pty_Column_Values(l_get_party_cursor_id, l_party_rec);
             l_count := l_count + 1;
               x_party_header_tbl(l_count)  := l_party_rec;
       END LOOP;

       -- Close the cursor
       DBMS_SQL.CLOSE_CURSOR(l_get_party_cursor_id);

       IF ((p_time_stamp IS NOT NULL) AND (p_time_stamp <> FND_API.G_MISS_DATE)) THEN

          IF p_time_stamp <= sysdate THEN
             -- contruct from the history if the p_time_stamp
             -- is < than sysdate
             csi_party_relationships_pvt.Construct_pty_from_hist(x_party_header_tbl, p_time_stamp);
         ELSE
            FND_MESSAGE.Set_Name('CSI', 'CSI_API_INVALID_HIST_PARAMS');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
       END IF;
--start of the new code for resolve_id_columns 08/24/01

   IF p_resolve_id_columns = fnd_api.g_true THEN

    IF x_party_header_tbl.count > 0 THEN

     FOR i IN x_party_header_tbl.FIRST.. x_party_header_tbl.LAST
       LOOP
          --l_contact_party_id := x_party_header_tbl(i).party_id ;
          l_contact_party_id := x_party_header_tbl(i).instance_party_id ;
          l_contact_flag     := x_party_header_tbl(i).contact_flag;
          l_party_source_tbl := x_party_header_tbl(i).party_source_table;

          csi_party_relationships_pvt.get_contact_details
          (
           p_api_version              =>  p_api_version
          ,p_commit                   =>  p_commit
          ,p_init_msg_list            =>  p_init_msg_list
          ,p_validation_level         =>  p_validation_level
          ,p_contact_party_id         =>  l_contact_party_id
          ,p_contact_flag             =>  l_contact_flag
          ,p_party_tbl                =>  l_party_source_tbl
          ,x_contact_details          =>  l_contact_details
          ,x_return_status            =>  x_return_status
          ,x_msg_count                =>  x_msg_count
          ,x_msg_data                 =>  x_msg_data
          );

       x_party_header_tbl(i).party_name        :=  l_contact_details.party_name;
       x_party_header_tbl(i).work_phone_number :=  l_contact_details.officephone;
       x_party_header_tbl(i).address1          :=  l_contact_details.address1;
       x_party_header_tbl(i).address2          :=  l_contact_details.address2;
       x_party_header_tbl(i).address3          :=  l_contact_details.address3;
       x_party_header_tbl(i).address4          :=  l_contact_details.address4;
       x_party_header_tbl(i).city              :=  l_contact_details.city;
       x_party_header_tbl(i).postal_code       :=  l_contact_details.postal_code;
       x_party_header_tbl(i).state             :=  l_contact_details.state;
       x_party_header_tbl(i).country           :=  l_contact_details.country;
       x_party_header_tbl(i).email_address     :=  l_contact_details.email;
-- Start of bug fix 2092790
            IF l_party_source_tbl = 'EMPLOYEE' THEN
              BEGIN
                SELECT pf.employee_number
                      ,cl.meaning           --party_type
                INTO   x_party_header_tbl(i).party_number
                      ,x_party_header_tbl(i).party_type
                FROM   per_all_people_f pf
                      ,csi_lookups cl
                      ,csi_item_instances cii
                WHERE  pf.person_id = x_party_header_tbl(i).party_id
                AND    cl.lookup_type=l_pty_lookup_type
                AND    cl.lookup_code=l_party_source_tbl
                AND    cii.instance_id=x_party_header_tbl(i).instance_id
                AND    pf.effective_end_date > SYSDATE
                AND    ROWNUM = 1   ;
              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;
            ELSIF l_party_source_tbl = 'HZ_PARTIES' THEN
              BEGIN
                SELECT hz.party_number
                      ,cl.meaning           --party_type
                      ,hz.party_name
                INTO   x_party_header_tbl(i).party_number
                      ,x_party_header_tbl(i).party_type
                      ,l_pty_name
                FROM   hz_parties hz
                      ,csi_lookups cl
                      ,csi_item_instances cii
                WHERE  party_id = x_party_header_tbl(i).party_id
                AND    cl.lookup_type=l_pty_lookup_type
                AND    cl.lookup_code=l_party_source_tbl
                AND    cii.instance_id=x_party_header_tbl(i).instance_id;

                IF x_party_header_tbl(i).party_name IS NULL OR
                   x_party_header_tbl(i).party_name = fnd_api.g_miss_char
                THEN
                   x_party_header_tbl(i).party_name :=l_pty_name;
                END IF;

              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;
            ELSIF l_party_source_tbl = 'PO_VENDORS' THEN
              BEGIN
                SELECT po.segment1
                      ,cl.meaning           --party_type
                INTO   x_party_header_tbl(i).party_number
                      ,x_party_header_tbl(i).party_type
                FROM   csi_lookups cl
                      ,csi_item_instances cii
                      ,po_vendors po
                WHERE  cl.lookup_type=l_pty_lookup_type
                AND    cl.lookup_code=l_party_source_tbl
                AND    cii.instance_id=x_party_header_tbl(i).instance_id
                AND    po.vendor_id = x_party_header_tbl(i).party_id;
              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;
            ELSIF l_party_source_tbl = 'TEAM' THEN
              BEGIN
                SELECT jt.team_number
                      ,cl.meaning           --party_type
                INTO   x_party_header_tbl(i).party_number
                      ,x_party_header_tbl(i).party_type
                FROM   jtf_rs_teams_vl jt
                      ,csi_lookups cl
                      ,csi_item_instances cii
                WHERE  jt.team_id = x_party_header_tbl(i).party_id
                and    cl.lookup_type=l_pty_lookup_type
                and    cl.lookup_code=l_party_source_tbl
                and    cii.instance_id=x_party_header_tbl(i).instance_id;
              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;
            ELSIF l_party_source_tbl = 'GROUP' THEN
              BEGIN
                SELECT jg.group_number
                      ,cl.meaning           --party_type
                INTO   x_party_header_tbl(i).party_number
                      ,x_party_header_tbl(i).party_type
                FROM   jtf_rs_groups_vl jg
                      ,csi_lookups cl
                      ,csi_item_instances cii
                WHERE  jg.group_id = x_party_header_tbl(i).party_id
                and    cl.lookup_type=l_pty_lookup_type
                and    cl.lookup_code=l_party_source_tbl
                and    cii.instance_id=x_party_header_tbl(i).instance_id;
              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;
            END IF;
-- End of bug fix 2092790


     END LOOP;
    END IF;
  END IF;
--end of the new code for resolve_id_columns 08/24/01
       --
       -- End of API body

       -- Standard check of p_commit.
       /*
       IF FND_API.To_Boolean( p_commit ) THEN
             COMMIT WORK;
       END IF;
       */

       /***** srramakr commented for bug # 3304439
       -- Check for the profile option and disable the trace
       IF (l_flag = 'Y') THEN
            dbms_session.set_sql_trace(false);
       END IF;
       -- End disable trace
       ****/

       -- Standard call to get message count and if count is  get message info.
       FND_MSG_PUB.Count_And_Get
                (p_count        =>      x_msg_count ,
                 p_data         =>      x_msg_data   );
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
              --  ROLLBACK TO get_inst_party_rel_pub;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (   p_count   =>      x_msg_count,
                    p_data    =>      x_msg_data );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              --  ROLLBACK TO get_inst_party_rel_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (   p_count   =>      x_msg_count,
                    p_data    =>      x_msg_data  );
        WHEN OTHERS THEN
                IF DBMS_SQL.IS_OPEN(l_get_party_cursor_id) THEN
                  DBMS_SQL.CLOSE_CURSOR(l_get_party_cursor_id);
                END IF;
              --  ROLLBACK TO get_inst_party_rel_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF      FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       g_pkg_name          ,
                        l_api_name           );
                END IF;
                FND_MSG_PUB.Count_And_Get
                ( p_count     =>      x_msg_count,
                  p_data      =>      x_msg_data  );

END get_inst_party_relationships;


/*-------------------------------------------------------------*/
/* Procedure name:  Create_inst_party_relationships            */
/* Description :  Procedure used to create new instance-party  */
/*                  relationships                              */
/*-------------------------------------------------------------*/

PROCEDURE create_inst_party_relationship
 (    p_api_version         IN     NUMBER
     ,p_commit              IN     VARCHAR2
     ,p_init_msg_list       IN     VARCHAR2
     ,p_validation_level    IN     NUMBER
     ,p_party_tbl           IN OUT NOCOPY csi_datastructures_pub.party_tbl
     ,p_party_account_tbl   IN OUT NOCOPY csi_datastructures_pub.party_account_tbl
     ,p_txn_rec             IN OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,p_oks_txn_inst_tbl    IN OUT NOCOPY oks_ibint_pub.txn_instance_tbl
     ,x_return_status       OUT NOCOPY    VARCHAR2
     ,x_msg_count           OUT NOCOPY    NUMBER
     ,x_msg_data            OUT NOCOPY    VARCHAR2
   ) IS
     l_api_name      CONSTANT VARCHAR2(30)   := 'CREATE_INST_PARTY_RELATIONSHIP';
     l_api_version   CONSTANT NUMBER         := 1.0;
     l_csi_debug_level        NUMBER;
     l_party_rec              csi_datastructures_pub.party_rec;
     l_party_has_correct_acct BOOLEAN := FALSE;
     l_internal_party_id      NUMBER;
     l_msg_index              NUMBER;
     l_msg_count              NUMBER;
     l_flag                   VARCHAR2(1)  :='N';
     l_party_source_tbl       csi_party_relationships_pvt.party_source_tbl;
     l_party_id_tbl           csi_party_relationships_pvt.party_id_tbl;
     l_contact_tbl            csi_party_relationships_pvt.contact_tbl;
     l_party_rel_type_tbl     csi_party_relationships_pvt.party_rel_type_tbl;
     l_party_count_rec        csi_party_relationships_pvt.party_count_rec;
     l_inst_party_tbl         csi_party_relationships_pvt.inst_party_tbl;
     l_acct_rel_type_tbl      csi_party_relationships_pvt.acct_rel_type_tbl;
     l_site_use_tbl           csi_party_relationships_pvt.site_use_tbl;
     l_account_count_rec      csi_party_relationships_pvt.account_count_rec;
     l_account_found          VARCHAR2(1)  :=NULL;
BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT    create_inst_party_rel_pub;

        -- Check for freeze_flag in csi_install_parameters is set to 'Y'

     csi_utility_grp.check_ib_active;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (    l_api_version           ,
                                                p_api_version           ,
                                                l_api_name              ,
                                                g_pkg_name              )
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- Check the profile option CSI_DEBUG_LEVEL for debug message reporting
        l_csi_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

        -- If CSI_DEBUG_LEVEL = 1 then dump the procedure name
        IF (l_csi_debug_level > 0) THEN
            csi_gen_utility_pvt.put_line( 'create_inst_party_relationship');
        END IF;


        -- If the debug level = 2 then dump all the parameters values.
        IF (l_csi_debug_level > 1) THEN
               csi_gen_utility_pvt.put_line( 'create_inst_party_relationship'||
                                                   p_api_version           ||'-'||
                                                   p_commit                ||'-'||
                                                   p_init_msg_list         ||'-'||
                                                   p_validation_level            );
               -- Dump the records in the log file
               csi_gen_utility_pvt.dump_party_tbl(p_party_tbl);
               csi_gen_utility_pvt.dump_party_account_tbl(p_party_account_tbl);
               csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);
        END IF;

        /***** srramakr commented for bug # 3304439
        -- Check for the profile option and enable trace
        l_flag:=csi_gen_utility_pvt.enable_trace(l_trace_flag => l_flag);
        -- End enable trace
        ****/

        -- Start API body
        --
        -- Grab the internal party id from csi_installed paramters
        IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
           csi_gen_utility_pvt.populate_install_param_rec;
        END IF;
        --
        l_internal_party_id := csi_datastructures_pub.g_install_param_rec.internal_party_id;
        --
        IF l_internal_party_id IS NULL THEN
           FND_MESSAGE.SET_NAME('CSI','CSI_API_UNINSTALLED_PARAMETER');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
        -- Check if the table is not empty and then loop
        IF p_party_tbl.count > 0 THEN
          FOR l_party_row IN p_party_tbl.FIRST..p_party_tbl.LAST LOOP
            IF p_party_tbl.EXISTS(l_party_row)  -- Added for bug 3776650
            THEN
             -- Find out if one of the accounts for external parties is an owner account
             IF ((p_party_tbl(l_party_row).party_source_table = 'HZ_PARTIES')
                 AND (p_party_tbl(l_party_row).party_id <> l_internal_party_id)
                 AND (p_party_tbl(l_party_row).relationship_type_code = 'OWNER')) THEN

                 l_party_has_correct_acct := FALSE;
                 IF p_party_account_tbl.COUNT > 0 THEN
                      FOR l_acct_row IN  p_party_account_tbl.FIRST..p_party_account_tbl.LAST LOOP
                        IF p_party_account_tbl.EXISTS(l_acct_row)  -- Added for bug 3776650
                        THEN
                         -- Check if the party and its accounts are mapped
                          IF ((p_party_account_tbl(l_acct_row).parent_tbl_index IS NULL)
                              OR (p_party_account_tbl(l_acct_row).parent_tbl_index = FND_API.G_MISS_NUM)
                              OR (NOT(p_party_tbl.EXISTS(p_party_account_tbl(l_acct_row).parent_tbl_index)))
                             ) THEN
                              FND_MESSAGE.SET_NAME('CSI','CSI_API_PARTY_ACCT_NOT_MAPPED');
                              FND_MSG_PUB.Add;
                              RAISE FND_API.G_EXC_ERROR;
                          END IF;

                          IF ((p_party_account_tbl(l_acct_row).parent_tbl_index = l_party_row)
                              AND (p_party_account_tbl(l_acct_row).relationship_type_code = 'OWNER')) THEN
                              l_party_has_correct_acct := TRUE;
                          END IF;
                        END IF;
                     END LOOP;
                 END IF;

                 -- Raise an exception if external parties don't have an owner account
                 IF NOT l_party_has_correct_acct THEN
                    FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_OWNER_ACCT');
                    FND_MESSAGE.SET_TOKEN('PARTY_ID',p_party_tbl(l_party_row).party_id);
                    FND_MSG_PUB.ADD;
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;

             END IF;

             -- Adding att enhancements by sguthiva
                 IF    p_party_tbl(l_party_row).contact_flag='Y'
                  AND (p_party_tbl(l_party_row).contact_ip_id IS NULL OR
                       p_party_tbl(l_party_row).contact_ip_id=fnd_api.g_miss_num )
                  AND (p_party_tbl(l_party_row).contact_parent_tbl_index IS NOT NULL AND
                       p_party_tbl(l_party_row).contact_parent_tbl_index <> fnd_api.g_miss_num )
                 THEN
                      FOR cont_row IN p_party_tbl.FIRST .. p_party_tbl.LAST
                      LOOP
                          IF cont_row=p_party_tbl(l_party_row).contact_parent_tbl_index
                          THEN
                             p_party_tbl(l_party_row).contact_ip_id:=p_party_tbl(cont_row).instance_party_id;
                          END IF;
                      END LOOP;
                 END IF;

              -- End of addition by sguthiva

              -- Call Private package to validate and create party relationship
             csi_party_relationships_pvt.create_inst_party_relationship
             ( p_api_version      => p_api_version
              ,p_commit           => p_commit
              ,p_init_msg_list    => p_init_msg_list
              ,p_validation_level => p_validation_level
              ,p_party_rec        => p_party_tbl(l_party_row)
              ,p_txn_rec          => p_txn_rec
              ,x_return_status    => x_return_status
              ,x_msg_count        => x_msg_count
              ,x_msg_data         => x_msg_data
	      ,p_party_source_tbl => l_party_source_tbl
	      ,p_party_id_tbl     => l_party_id_tbl
	      ,p_contact_tbl      => l_contact_tbl
	      ,p_party_rel_type_tbl => l_party_rel_type_tbl
	      ,p_party_count_rec  => l_party_count_rec
             ) ;

              IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  l_msg_index := 1;
                  l_msg_count := x_msg_count;
                  WHILE l_msg_count > 0 LOOP
                      x_msg_data := FND_MSG_PUB.GET
                          (  l_msg_index,
                             FND_API.G_FALSE    );
                      csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
                      l_msg_index := l_msg_index + 1;
                      l_msg_count := l_msg_count - 1;
                  END LOOP;
                  RAISE FND_API.G_EXC_ERROR;
              END IF;
            END IF;
          END LOOP; -- End of party loop
        END IF; -- End of party count if

        -- Create party accounts
        IF (p_party_account_tbl.COUNT > 0) THEN
             FOR l_acct_row IN  p_party_account_tbl.FIRST..p_party_account_tbl.LAST LOOP
               IF p_party_account_tbl.EXISTS(l_acct_row) THEN
                   IF ((p_party_account_tbl(l_acct_row).parent_tbl_index IS NULL)
                          OR (p_party_account_tbl(l_acct_row).parent_tbl_index = FND_API.G_MISS_NUM)
                          OR (NOT(p_party_tbl.EXISTS(p_party_account_tbl(l_acct_row).parent_tbl_index)))
                      ) THEN
                       FND_MESSAGE.SET_NAME('CSI','CSI_API_PARTY_ACCT_NOT_MAPPED');
                       FND_MSG_PUB.Add;
                       RAISE FND_API.G_EXC_ERROR;
                   END IF;

                   p_party_account_tbl(l_acct_row).instance_party_id :=
                           p_party_tbl(p_party_account_tbl(l_acct_row).parent_tbl_index).instance_party_id;
                   -- Strat Addition for bug 1893100
                   IF   p_party_account_tbl(l_acct_row).active_start_date IS NULL
                     OR p_party_account_tbl(l_acct_row).active_start_date = fnd_api.g_miss_date
                     AND (p_party_account_tbl(l_acct_row).ip_account_id IS NULL
                      OR  p_party_account_tbl(l_acct_row).ip_account_id = fnd_api.g_miss_num)
                   THEN
                   p_party_account_tbl(l_acct_row).active_start_date :=
                           p_party_tbl(p_party_account_tbl(l_acct_row).parent_tbl_index).active_start_date;
                   END IF;
                   -- End Addition for bug 1893100
                   -- The following code has been added for bug 2990027
                   -- to avoid lock record error.
                   BEGIN
                     l_account_found:=NULL;
                     SELECT 'x'
                     INTO   l_account_found
                     FROM   csi_ip_accounts
                     WHERE  ip_account_id =p_party_account_tbl(l_acct_row).ip_account_id;
                   EXCEPTION
                     WHEN OTHERS THEN
                       l_account_found:=NULL;
                   END ;
                   -- End addition.

                   -- Call Private package to validate and create party accounts
                   IF  p_party_account_tbl(l_acct_row).ip_account_id IS NOT NULL
                   AND p_party_account_tbl(l_acct_row).ip_account_id <> fnd_api.g_miss_num
                   AND l_account_found IS NOT NULL
                   THEN
                    csi_party_relationships_pvt.update_inst_party_account
                    ( p_api_version         => p_api_version
                     ,p_commit              => p_commit
                     ,p_init_msg_list       => p_init_msg_list
                     ,p_validation_level    => p_validation_level
                     ,p_party_account_rec   => p_party_account_tbl(l_acct_row)
                     ,p_txn_rec             => p_txn_rec
                     ,p_oks_txn_inst_tbl    => p_oks_txn_inst_tbl
                     ,x_return_status       => x_return_status
                     ,x_msg_count           => x_msg_count
                     ,x_msg_data            => x_msg_data);
                   ELSE
                   csi_party_relationships_pvt.create_inst_party_account
                   ( p_api_version         => p_api_version
                    ,p_commit              => p_commit
                    ,p_init_msg_list       => p_init_msg_list
                    ,p_validation_level    => p_validation_level
                    ,p_party_account_rec   => p_party_account_tbl(l_acct_row)
                    ,p_txn_rec             => p_txn_rec
                    ,x_return_status       => x_return_status
                    ,x_msg_count           => x_msg_count
                    ,x_msg_data            => x_msg_data
                    ,p_inst_party_tbl      => l_inst_party_tbl
                    ,p_acct_rel_type_tbl   => l_acct_rel_type_tbl
                    ,p_site_use_tbl        => l_site_use_tbl
                    ,p_account_count_rec   => l_account_count_rec
                    ,p_oks_txn_inst_tbl    => p_oks_txn_inst_tbl
                  );

                   END IF;

                    IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                           l_msg_index := 1;
                           l_msg_count := x_msg_count;
                           WHILE l_msg_count > 0 LOOP
                              x_msg_data := FND_MSG_PUB.GET(
                                                   l_msg_index,
                                                   FND_API.G_FALSE );
                              csi_gen_utility_pvt.put_line( 'message data = '||x_msg_data);
                              l_msg_index := l_msg_index + 1;
                              l_msg_count := l_msg_count - 1;
                           END LOOP;
                           RAISE FND_API.G_EXC_ERROR;
                     END IF;
                END IF;
             END LOOP;
         END IF;


        --
        -- End of API body
        -- Standard check of p_commit.

        IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT WORK;
        END IF;

        /***** srramakr commented for bug # 3304439
        -- Check for the profile option and disable the trace
        IF (l_flag = 'Y') THEN
            dbms_session.set_sql_trace(false);
        END IF;
        -- End disable trace
        ****/

        -- Standard call to get message count and if count is  get message info.
        FND_MSG_PUB.Count_And_Get
                (p_count        =>      x_msg_count ,
                 p_data         =>      x_msg_data   );
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                x_return_status := FND_API.G_RET_STS_ERROR ;
                ROLLBACK TO create_inst_party_rel_pub;
                FND_MSG_PUB.Count_And_Get
                (       p_count      =>      x_msg_count,
                        p_data       =>      x_msg_data   );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                ROLLBACK TO create_inst_party_rel_pub;
                FND_MSG_PUB.Count_And_Get
                (       p_count   =>      x_msg_count,
                        p_data    =>      x_msg_data  );

        WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                ROLLBACK TO create_inst_party_rel_pub;
                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.Add_Exc_Msg
                (       g_pkg_name          ,
                        l_api_name         );
                END IF;
                FND_MSG_PUB.Count_And_Get
                 (      p_count    =>      x_msg_count,
                        p_data     =>      x_msg_data  );
END  create_inst_party_relationship;

/*-------------------------------------------------------------*/
/* Procedure name:  Update_inst_party_relationship             */
/* Description :   Procedure used to  update the existing      */
/*                instance -party relationships                */
/*-------------------------------------------------------------*/


PROCEDURE update_inst_party_relationship
 (    p_api_version                 IN     NUMBER
     ,p_commit                      IN     VARCHAR2
     ,p_init_msg_list               IN     VARCHAR2
     ,p_validation_level            IN     NUMBER
     ,p_party_tbl                   IN     csi_datastructures_pub.party_tbl
     ,p_party_account_tbl           IN OUT NOCOPY csi_datastructures_pub.party_account_tbl
     ,p_txn_rec                     IN OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,p_oks_txn_inst_tbl            IN OUT NOCOPY oks_ibint_pub.txn_instance_tbl
     ,x_return_status               OUT NOCOPY    VARCHAR2
     ,x_msg_count                   OUT NOCOPY    NUMBER
     ,x_msg_data                    OUT NOCOPY    VARCHAR2
 ) IS
      l_api_name      CONSTANT VARCHAR2(30)   := 'UPDATE_INST_PARTY_RELATIONSHIP';
      l_api_version   CONSTANT NUMBER         := 1.0;
      l_csi_debug_level        NUMBER;
      l_party_rec              csi_datastructures_pub.party_rec;
      l_temp_party_rec         csi_datastructures_pub.party_rec;
      l_curr_party_rec         csi_datastructures_pub.party_rec;
      l_exp_party_rec          csi_datastructures_pub.party_rec;
      l_party_tbl              csi_datastructures_pub.party_tbl;
      l_internal_party_id      NUMBER;
      l_party_has_correct_acct BOOLEAN := FALSE;
      l_msg_index              NUMBER;
      l_msg_count              NUMBER;
      l_line_count             NUMBER;
      l_flag                   VARCHAR2(1)  :='N';
      l_inst_party_tbl         csi_party_relationships_pvt.inst_party_tbl;
      l_acct_rel_type_tbl      csi_party_relationships_pvt.acct_rel_type_tbl;
      l_site_use_tbl           csi_party_relationships_pvt.site_use_tbl;
      l_account_count_rec      csi_party_relationships_pvt.account_count_rec;
      p_rel_query_rec          csi_datastructures_pub.relationship_query_rec;
      l_rel_tbl                csi_datastructures_pub.ii_relationship_tbl;
      l_ii_relationship_level_tbl csi_ii_relationships_pvt.ii_relationship_level_tbl;

-- Added by sk on 12/06/01 for contracts TRF fix bug 2133944

   CURSOR acct_csr (p_ins_pty_id IN NUMBER) IS
     SELECT acct.party_account_id
           ,acct.active_end_date
           ,pty.instance_id
     FROM   csi_ip_accounts acct
           ,csi_i_parties pty
     WHERE  acct.instance_party_id = p_ins_pty_id
     AND    acct.relationship_type_code = 'OWNER'
     AND    ((acct.active_end_date IS NULL) OR (acct.active_end_date>SYSDATE))
     AND    pty.instance_party_id= acct.instance_party_id;
 -- Following cursor has been added for fixing the bug 2151750
/*   CURSOR party_csr (p_object_id IN NUMBER) IS
     SELECT instance_id subject_id  -- added by sguthiva for 2608706
     FROM csi_item_instances
     WHERE instance_id IN(
        SELECT subject_id
        FROM   csi_ii_relationships
        WHERE  relationship_type_code = 'COMPONENT-OF'
        START WITH object_id = p_object_id
        CONNECT BY object_id = PRIOR subject_id)
     AND (active_end_date IS NULL OR active_end_date> SYSDATE); */

   CURSOR old_party_csr (p_ins_pty_id IN NUMBER) IS
     SELECT instance_party_id,
            party_id
     FROM   csi_i_parties
     WHERE  instance_party_id = p_ins_pty_id
     AND    relationship_type_code = 'OWNER'
     AND    (active_end_date IS NULL OR active_end_date > sysdate);

   CURSOR exp_pty_csr (p_ins_id IN NUMBER) IS
     SELECT instance_party_id,
            party_id,
            relationship_type_code,
            object_version_number,
            active_end_date -- Added for bug 7333900
     FROM   csi_i_parties
     WHERE  instance_id = p_ins_id
     AND    relationship_type_code<>'OWNER'
     AND    (active_end_date IS NULL
     OR     (to_date(active_end_date,'DD-MM-YY HH24:MI') > to_date(sysdate,'DD-MM-YY HH24:MI'))); -- Modified for bug 7333900

     --included for bug 5511689
     CURSOR exp_acct_csr (p_inst_party_id IN NUMBER) IS
     SELECT ip_account_id,
            relationship_type_code,
            object_version_number,
            active_end_date -- Added for bug 7333900
     FROM   csi_ip_accounts
     WHERE  instance_party_id=p_inst_party_id
     AND    relationship_type_code <>'OWNER'
     AND    nvl(active_end_date, sysdate+1) >= sysdate;
     --end of fix

      l_acct_csr               acct_csr%ROWTYPE;
      l_old_party_csr          old_party_csr%ROWTYPE;
      l_acct_tbl               csi_datastructures_pub.party_account_tbl;
      l_count                  NUMBER;
      la_count                 NUMBER;
      l_act_tbl                csi_datastructures_pub.party_account_tbl;
      l_row                    NUMBER;
      l_obj_ver_number         NUMBER;
      l_found                  BOOLEAN := FALSE;
      l_end_date               DATE;

 -- End Addition by sk on 12/06/01 for contracts TRF fix bug 2133944
 -- Start of code addition for fixing the bug 2151750
      l_old_party_tbl          csi_datastructures_pub.party_tbl := p_party_tbl;
      l_cld_party_rec          csi_datastructures_pub.party_rec;
      l_new_curr_party_rec     csi_datastructures_pub.party_rec;
      l_ip_acct_rec            csi_datastructures_pub.party_account_rec;
      l_temp_acct_rec          csi_datastructures_pub.party_account_rec;
      l_new_ip_acct_rec        csi_datastructures_pub.party_account_rec;
      l_pty_count              NUMBER;
      lp_count                 NUMBER;
      lpa_count                NUMBER;
      l_cld_party_id           NUMBER;
      l_cld_party_acct_id      NUMBER;
      l_last_vld_org           NUMBER;
      l_last_vld_org1          NUMBER;
      l_exp_acct_rec           csi_datastructures_pub.party_account_rec; -- Added by sguthiva for bug 2307804
      l_grp_call_contracts     VARCHAR2(1);
   -- End of code addition for fixing the bug 2151750
   -- Start of code addition for fixing bug 6368172, section 1 of 5
      l_old_parent_owner_pty_acct_id  NUMBER;
      l_old_child_owner_pty_acct_id   NUMBER;
   -- End of code addition for fixing bug 6368172, section 1 of 5
BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT    update_inst_party_rel_pub  ;

     -- Check for freeze_flag in csi_install_parameters is set to 'Y'

     csi_utility_grp.check_ib_active;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (    l_api_version           ,
                                                p_api_version           ,
                                                l_api_name              ,
                                                g_pkg_name              )
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;


        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- Check the profile option CSI_DEBUG_LEVEL for debug message reporting
        l_csi_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

        -- If CSI_DEBUG_LEVEL = 1 then dump the procedure name
        IF (l_csi_debug_level > 0) THEN
            csi_gen_utility_pvt.put_line( 'update_inst_party_relationship ');
        END IF;


        -- If the debug level = 2 then dump all the parameters values.
        IF (l_csi_debug_level > 1) THEN
            csi_gen_utility_pvt.put_line( 'update_inst_party_relationship:'  ||
                                          p_api_version     ||'-'||
                                          p_commit          ||'-'||
                                          p_init_msg_list   ||'-'||
                                          p_validation_level      );
            -- Dump the records in the log file
            csi_gen_utility_pvt.dump_party_tbl(p_party_tbl);
            csi_gen_utility_pvt.dump_party_account_tbl(p_party_account_tbl);
            csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);

        END IF;

        /***** srramakr commented for bug # 3304439
        -- Check for the profile option and enable trace
        l_flag:=csi_gen_utility_pvt.enable_trace(l_trace_flag => l_flag);
        -- End enable trace
        ****/

        -- Start API body
        --
        -- Assign the value for l_grp_call_contracts
        -- Since all the records will have the same value for grp_call_contracts, we just take the first one.
        l_grp_call_contracts := FND_API.G_FALSE;
        IF p_party_account_tbl.count > 0 THEN
           FOR tab_row in p_party_account_tbl.FIRST .. p_party_account_tbl.LAST
           LOOP
              IF p_party_account_tbl.EXISTS(tab_row) THEN
                 l_grp_call_contracts := p_party_account_tbl(tab_row).grp_call_contracts;
                 EXIT;
              END IF;
           END LOOP;
        END IF;
        --
        -- Grab the internal party id from csi_installed paramters
        -- Added by sk on 12/06/01 for contracts TRF fix bug 2133944
        -- End  Added by sk on 12/06/01 for contracts TRF fix bug 2133944
        -- Added for bug 2151750
        -- The following code has been written to grab the old owner party_id
        -- for an instance.
         l_pty_count:= p_party_tbl.count;
         lp_count:=0;
         IF l_pty_count > 0 THEN
          FOR p_csr IN 1..l_pty_count
          LOOP
            IF p_party_tbl(p_csr).relationship_type_code = 'OWNER'
            THEN
              OPEN old_party_csr (p_party_tbl(p_csr).instance_party_id);
              FETCH old_party_csr into l_old_party_csr;
               IF   old_party_csr%FOUND
               THEN
                 lp_count:=lp_count+1;
                 l_old_party_tbl(lp_count).instance_party_id      := l_old_party_csr.instance_party_id;
                 l_old_party_tbl(lp_count).party_id               := l_old_party_csr.party_id;
                 l_old_party_tbl(lp_count).cascade_ownership_flag := nvl(p_party_tbl(p_csr).cascade_ownership_flag,'N'); --Added for cascade 2972082
          -- The following code has been written to grab the old owner party_id
          -- for an instance.
                 lpa_count:= p_party_account_tbl.count;
                IF lpa_count > 0 THEN
                 FOR pa_csr IN 1..lpa_count
                 LOOP
                   IF p_party_account_tbl(pa_csr).instance_party_id = l_old_party_tbl(lp_count).instance_party_id AND
                      p_party_account_tbl(pa_csr).relationship_type_code ='OWNER'
                   THEN
          -- The following line has been written to grab the vld_organization_id
          -- of the account.
                     l_old_party_tbl(lp_count).attribute1      := p_party_account_tbl(pa_csr).vld_organization_id;
                     EXIT;
                   END IF;
                 END LOOP;
                END IF; -- end if for lpa_count > 0
               END IF;  -- end if for old_party_csr%FOUND
              CLOSE old_party_csr;
            END IF;     -- end if for p_party_tbl(p_csr).relationship_type_code = 'OWNER'
          END LOOP;     -- end loop for p_csr IN 1..l_count
         END IF;        -- end if for l_pty_count > 0
          -- End addition for bug 2151750
        --
        IF csi_datastructures_pub.g_install_param_rec.fetch_flag IS NULL THEN
           csi_gen_utility_pvt.populate_install_param_rec;
        END IF;
        --
        l_internal_party_id := csi_datastructures_pub.g_install_param_rec.internal_party_id;
        --
        IF l_internal_party_id IS NULL THEN
           FND_MESSAGE.SET_NAME('CSI','CSI_API_UNINSTALLED_PARAMETER');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
        -- Check if the table is not empty
        IF p_party_tbl.count > 0 THEN
          FOR l_party_row IN p_party_tbl.FIRST..p_party_tbl.LAST LOOP
            IF p_party_tbl.EXISTS(l_party_row) THEN

              -- Get Current Party record
              IF NOT(CSI_Instance_parties_vld_pvt.Get_Party_Record
                     ( p_party_tbl(l_party_row).instance_party_id,
                       l_curr_party_rec)) THEN
                      RAISE FND_API.G_EXC_ERROR;
              END IF;

              -- Check if this is Transfer of ownership (i.e. owner to a new owner)
              -- If so, then a new owner account is needed for the new party
              IF ((p_party_tbl(l_party_row).PARTY_ID <> FND_API.G_MISS_NUM)
                AND (p_party_tbl(l_party_row).PARTY_ID IS NOT NULL)
                AND (p_party_tbl(l_party_row).party_id <> l_internal_party_id)
                AND (p_party_tbl(l_party_row).PARTY_ID <> l_curr_party_rec.PARTY_ID)
                AND (p_party_tbl(l_party_row).PARTY_SOURCE_TABLE = 'HZ_PARTIES')
                AND (p_party_tbl(l_party_row).RELATIONSHIP_TYPE_CODE = l_curr_party_rec.RELATIONSHIP_TYPE_CODE )
                AND (p_party_tbl(l_party_row).RELATIONSHIP_TYPE_CODE = 'OWNER'
))
               THEN

                 -- Find out if one of the accounts for external parties is an owner account
                 l_party_has_correct_acct := FALSE;
                 IF p_party_account_tbl.COUNT > 0 THEN
                      FOR l_acct_row IN  p_party_account_tbl.FIRST..p_party_account_tbl.LAST LOOP
                        IF p_party_account_tbl.EXISTS(l_acct_row)  -- Added for bug 3776650
                        THEN
                         -- Check if the party and its accounts are mapped
                          IF ((p_party_account_tbl(l_acct_row).parent_tbl_index IS NULL)
                              OR (p_party_account_tbl(l_acct_row).parent_tbl_index = FND_API.G_MISS_NUM)
                              OR (NOT(p_party_tbl.EXISTS(p_party_account_tbl(l_acct_row).parent_tbl_index)))
                             ) THEN
                              FND_MESSAGE.SET_NAME('CSI','CSI_API_PARTY_ACCT_NOT_MAPPED');
                              FND_MSG_PUB.Add;
                              RAISE FND_API.G_EXC_ERROR;
                          END IF;

                          IF ((p_party_account_tbl(l_acct_row).parent_tbl_index = l_party_row)
                              AND (p_party_account_tbl(l_acct_row).relationship_type_code = 'OWNER')) THEN
                              l_party_has_correct_acct := TRUE;
                              -- Check whether bill_to and ship_to are passed. If not make them null
                              IF p_party_account_tbl(l_acct_row).bill_to_address IS NULL OR
                                 p_party_account_tbl(l_acct_row).bill_to_address = FND_API.G_MISS_NUM THEN
                                 p_party_account_tbl(l_acct_row).bill_to_address := NULL;
                              END IF;
                              --
                              IF p_party_account_tbl(l_acct_row).ship_to_address IS NULL OR
                                 p_party_account_tbl(l_acct_row).ship_to_address = FND_API.G_MISS_NUM THEN
                                 p_party_account_tbl(l_acct_row).ship_to_address := NULL;
                              END IF;
                              --
                          END IF;
                        END IF;
                     END LOOP;
                 END IF; -- End of Transfer of Ownership check

                 -- Raise an exception if external parties don't have an owner account
                 IF NOT l_party_has_correct_acct THEN
                    FND_MESSAGE.SET_NAME('CSI','CSI_API_INVALID_OWNER_ACCT');
                    FND_MESSAGE.SET_TOKEN('PARTY_ID',p_party_tbl(l_party_row).party_id);
                    FND_MSG_PUB.ADD;
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;

               END IF;


              l_party_rec.instance_party_id := p_party_tbl(l_party_row).instance_party_id ;
              l_party_rec.instance_id       := p_party_tbl(l_party_row).instance_id;
              l_party_rec.party_source_table := p_party_tbl(l_party_row).party_source_table ;
              l_party_rec.party_id          := p_party_tbl(l_party_row).party_id ;
              l_party_rec.relationship_type_code := p_party_tbl(l_party_row).relationship_type_code;
              l_party_rec.contact_flag      := p_party_tbl(l_party_row).contact_flag;
              l_party_rec.contact_ip_id     := p_party_tbl(l_party_row).contact_ip_id;
              l_party_rec.active_start_date := p_party_tbl(l_party_row).active_start_date;
              l_party_rec.active_end_date   := p_party_tbl(l_party_row).active_end_date;
              l_party_rec.context           := p_party_tbl(l_party_row).context;
              l_party_rec.attribute1        := p_party_tbl(l_party_row). attribute1;
              l_party_rec.attribute2        := p_party_tbl(l_party_row).attribute2;
              l_party_rec.attribute3        := p_party_tbl(l_party_row).attribute3;
              l_party_rec.attribute4        := p_party_tbl(l_party_row).attribute4;
              l_party_rec.attribute5        := p_party_tbl(l_party_row).attribute5;
              l_party_rec.attribute6        := p_party_tbl(l_party_row).attribute6;
              l_party_rec.attribute7        := p_party_tbl(l_party_row).attribute7;
              l_party_rec.attribute8        := p_party_tbl(l_party_row).attribute8;
              l_party_rec.attribute9        := p_party_tbl(l_party_row).attribute9;
              l_party_rec.attribute10       := p_party_tbl(l_party_row).attribute10;
              l_party_rec.attribute11       := p_party_tbl(l_party_row).attribute11;
              l_party_rec.attribute12       := p_party_tbl(l_party_row).attribute12;
              l_party_rec.attribute13       := p_party_tbl(l_party_row).attribute13;
              l_party_rec.attribute14       := p_party_tbl(l_party_row).attribute14;
              l_party_rec.attribute15       := p_party_tbl(l_party_row).attribute15;
              l_party_rec.preferred_flag    := p_party_tbl(l_party_row).preferred_flag;
              l_party_rec.primary_flag    := p_party_tbl(l_party_row).primary_flag;
              l_party_rec.object_version_number := p_party_tbl(l_party_row).object_version_number;

              -- Start of code addition for fixing bug 6368172, section 2 of 5
              -- Need to grab the account id before it gets changed
              IF l_party_rec.instance_party_id IS NOT NULL THEN
                BEGIN
                  SELECT party_account_id
                  INTO l_old_parent_owner_pty_acct_id
                  FROM csi_ip_accounts
                  WHERE instance_party_id = l_party_rec.instance_party_id
                  AND relationship_type_code = 'OWNER';
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    l_old_parent_owner_pty_acct_id := NULL;
                END;
              END IF;
              -- End of code addition for fixing bug 6368172, section 2 of 5

           -- added by sk on 12/07 for accounts fix
                IF p_party_account_tbl.COUNT > 0 THEN
                     FOR l_row IN  p_party_account_tbl.FIRST..p_party_account_tbl.LAST LOOP
                        IF p_party_account_tbl.EXISTS(l_row) THEN
                           l_obj_ver_number := NULL;
                         BEGIN
                          IF   p_party_account_tbl(l_row).ip_account_id IS NOT NULL
                           AND p_party_account_tbl(l_row).ip_account_id <> fnd_api.g_miss_num
                          THEN
                           SELECT acct.object_version_number
                           INTO   l_obj_ver_number
                           FROM   csi_ip_accounts acct
                           WHERE  acct.ip_account_id= p_party_account_tbl(l_row).ip_account_id;
                          END IF;
                         EXCEPTION
                           WHEN OTHERS THEN
                            l_obj_ver_number := NULL;
                         END;
                          IF  (p_party_account_tbl(l_row).ip_account_id IS NOT NULL AND p_party_account_tbl(l_row).ip_account_id <> fnd_api.g_miss_num)
                          AND  p_party_account_tbl(l_row).relationship_type_code = 'OWNER'
                          AND  p_party_account_tbl(l_row).instance_party_id = l_party_rec.instance_party_id
                          AND  p_party_account_tbl(l_row).object_version_number = l_obj_ver_number
                          THEN
                               l_act_tbl(l_party_row).attribute1:='Y';
                               l_act_tbl(l_party_row).ip_account_id :=p_party_account_tbl(l_row).ip_account_id;
                          END IF;
                        END IF;
                     END LOOP;
                END IF;
              -- end of addition by sk on 12/07 for accounts fix

             csi_party_relationships_pvt.update_inst_party_relationship
                ( p_api_version      => p_api_version
                 ,p_commit           => p_commit
                 ,p_init_msg_list    => p_init_msg_list
                 ,p_validation_level => p_validation_level
                 ,p_party_rec        => l_party_rec
                 ,p_txn_rec          => p_txn_rec
                 ,x_return_status    => x_return_status
                 ,x_msg_count        => x_msg_count
                 ,x_msg_data         => x_msg_data  ) ;

              IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                     l_msg_index := 1;
                     l_msg_count := x_msg_count;
                     WHILE l_msg_count > 0 LOOP
                           x_msg_data := FND_MSG_PUB.GET(
                                                l_msg_index,
                                                FND_API.G_FALSE );
                           csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
                           l_msg_index := l_msg_index + 1;
                           l_msg_count := l_msg_count - 1;
                     END LOOP;
                     RAISE FND_API.G_EXC_ERROR;
              ELSE
                 -- Grab the new party rec
                 l_party_tbl(l_party_row) := l_party_rec;
              END IF;
            END IF;
          END LOOP;

        END IF;

        -- Update accounts
        -- Check if the table is not empty
        IF p_party_account_tbl.count > 0 THEN
           FOR l_acct_row IN p_party_account_tbl.FIRST..p_party_account_tbl.LAST LOOP
             IF p_party_account_tbl.EXISTS(l_acct_row) THEN


              IF ( (p_party_account_tbl(l_acct_row).ip_account_id IS NULL)
                 OR
                   (p_party_account_tbl(l_acct_row).ip_account_id = FND_API.G_MISS_NUM) ) THEN
                   -- Call Private package to validate and create party accounts
                   csi_party_relationships_pvt.create_inst_party_account
                   ( p_api_version         => p_api_version
                    ,p_commit              => p_commit
                    ,p_init_msg_list       => p_init_msg_list
                    ,p_validation_level    => p_validation_level
                    ,p_party_account_rec   => p_party_account_tbl(l_acct_row)
                    ,p_txn_rec             => p_txn_rec
                    ,x_return_status       => x_return_status
                    ,x_msg_count           => x_msg_count
                    ,x_msg_data            => x_msg_data
                    ,p_inst_party_tbl      => l_inst_party_tbl
                    ,p_acct_rel_type_tbl   => l_acct_rel_type_tbl
                    ,p_site_use_tbl        => l_site_use_tbl
                    ,p_account_count_rec   => l_account_count_rec
                    ,p_oks_txn_inst_tbl    => p_oks_txn_inst_tbl
                   );
              ELSE
              -- dbms_output.put_line('PUB: caling update_inst_party_account');
              -- added by sk on 12/07 for accounts fix

             l_found := FALSE;
             IF l_act_tbl.COUNT > 0 THEN
		FOR l_arow IN  l_act_tbl.FIRST..l_act_tbl.LAST LOOP
		  IF l_found
		  THEN
		     EXIT;
		  END IF;
		   IF l_act_tbl.EXISTS(l_arow) THEN
		      IF   l_act_tbl(l_arow).ip_account_id = p_party_account_tbl(l_acct_row).ip_account_id
		       AND l_act_tbl(l_arow).attribute1 = 'Y'
		      THEN
			l_found := TRUE;
			BEGIN
			   SELECT acct.object_version_number
			   INTO   p_party_account_tbl(l_arow).object_version_number
			   FROM   csi_ip_accounts acct
			   WHERE  acct.ip_account_id= p_party_account_tbl(l_arow).ip_account_id;
			EXCEPTION
			  WHEN OTHERS THEN
			    NULL;
			END;
		      END IF;
		   END IF;
		END LOOP;
             END IF;
          -- End addition by sk on 12/07 for accounts fix
             -- srramakr Fix for Bug # 3117552
	     IF p_txn_rec.transaction_type_id = 7 THEN -- only for Account Merge
		BEGIN
		   SELECT acct.object_version_number,acct.active_end_date
		   INTO   p_party_account_tbl(l_acct_row).object_version_number,l_end_date
		   FROM   csi_ip_accounts acct
		   WHERE  acct.ip_account_id= p_party_account_tbl(l_acct_row).ip_account_id;
             -- Commenting for bug 3692167 as it will fail the unique constraint.
             -- At any time there should be one active record in combination of
             -- (party_account_id,relationship_type_code) associated to an
             -- party entity.
             /*
                   IF nvl(l_end_date,(sysdate+1)) <= sysdate THEN
                      p_party_account_tbl(l_acct_row).active_end_date := NULL;
                   END IF;
              */
		EXCEPTION
		  WHEN OTHERS THEN
		    NULL;
		END;
	     END IF;
	     --
               csi_party_relationships_pvt.update_inst_party_account
                (     p_api_version         => p_api_version
                     ,p_commit              => p_commit
                     ,p_init_msg_list       => p_init_msg_list
                     ,p_validation_level    => p_validation_level
                     ,p_party_account_rec   => p_party_account_tbl(l_acct_row)
                     ,p_txn_rec             => p_txn_rec
                     ,p_oks_txn_inst_tbl    => p_oks_txn_inst_tbl
                     ,x_return_status       => x_return_status
                     ,x_msg_count           => x_msg_count
                     ,x_msg_data            => x_msg_data);
              END IF;

               IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                    l_msg_index := 1;
                    l_msg_count := x_msg_count;
                    WHILE l_msg_count > 0 LOOP
                        x_msg_data := FND_MSG_PUB.GET(
                                              l_msg_index,
                                              FND_API.G_FALSE   );
                        csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
                        l_msg_index := l_msg_index + 1;
                        l_msg_count := l_msg_count - 1;
                    END LOOP;
                    RAISE FND_API.G_EXC_ERROR;
               END IF;
            END IF;
          END LOOP;
        -- Added by sguthiva for bug 2307804
        ELSE
        -- The following code has wrritten specifically for expiring the ownership of
        -- an external party during the transfer of ownership from external to internal.

          FOR p_row IN p_party_tbl.FIRST..p_party_tbl.LAST
          LOOP
             FOR l_row IN  l_old_party_tbl.FIRST..l_old_party_tbl.LAST
             LOOP
                 IF   l_old_party_tbl(l_row).instance_party_id = p_party_tbl(p_row).instance_party_id
                  AND l_old_party_tbl(l_row).party_id <> l_internal_party_id
                  AND p_party_tbl(p_row).party_id = l_internal_party_id
                 OR ((l_old_party_tbl(l_row).instance_party_id = p_party_tbl(p_row).instance_party_id)
                  AND (p_party_tbl(p_row).party_source_table IN ('EMPLOYEE', 'PO_VENDORS')))
                 THEN
                   -- Adding for bug 3294748
                   -- Wrote the following code to expire all non-owner parties and its contacts (if any)
                   -- in the case of ownership transfer from external-to-internal party,
                   -- however we do not expire non-owner accounts.
                   IF   l_old_party_tbl(l_row).instance_party_id = p_party_tbl(p_row).instance_party_id
                    AND l_old_party_tbl(l_row).party_id <> l_internal_party_id
                    AND p_party_tbl(p_row).party_id = l_internal_party_id
                    AND (  p_party_tbl(p_row).instance_id IS NOT NULL AND
                           p_party_tbl(p_row).instance_id <> fnd_api.g_miss_num)
                    AND p_party_tbl(p_row).relationship_type_code='OWNER'
                   THEN
                     FOR l_exp_pty IN exp_pty_csr(p_party_tbl(p_row).instance_id)
                     LOOP
                       l_exp_party_rec:= l_temp_party_rec;
                       l_exp_party_rec.instance_id:= p_party_tbl(p_row).instance_id;
                       l_exp_party_rec.instance_party_id := l_exp_pty.instance_party_id;
                       l_exp_party_rec.relationship_type_code := l_exp_pty.relationship_type_code;
                       l_exp_party_rec.object_version_number := l_exp_pty.object_version_number;
                       -- Bug 3804960
                       -- srramakr Need to use the same the date used by the item instance
                       IF p_txn_rec.src_txn_creation_date IS NULL OR
                          p_txn_rec.src_txn_creation_date = FND_API.G_MISS_DATE THEN
                          l_exp_party_rec.active_end_date := sysdate;
                       ELSE
                          l_exp_party_rec.active_end_date := p_txn_rec.src_txn_creation_date;
                       END IF;
                       -- End of 3804960
                       -- Add log output for bug 7333900
                       IF (l_csi_debug_level > 0) THEN
                         csi_gen_utility_pvt.put_line('Expiring party record '||l_exp_party_rec.instance_party_id||' of party type '||l_exp_party_rec.relationship_type_code);
                         csi_gen_utility_pvt.put_line(' party old active_end_date : '||l_exp_pty.active_end_date);
                         csi_gen_utility_pvt.put_line(' party new active_end_date : '||l_exp_party_rec.active_end_date);
                         csi_gen_utility_pvt.put_line(' sysdate                   : '||SYSDATE);
                       END IF;
                       csi_party_relationships_pvt.update_inst_party_relationship
                         ( p_api_version      => p_api_version
                          ,p_commit           => p_commit
                          ,p_init_msg_list    => p_init_msg_list
                          ,p_validation_level => p_validation_level
                          ,p_party_rec        => l_exp_party_rec
                          ,p_txn_rec          => p_txn_rec
                          ,x_return_status    => x_return_status
                          ,x_msg_count        => x_msg_count
                          ,x_msg_data         => x_msg_data  ) ;

                          IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                             l_msg_index := 1;
                             l_msg_count := x_msg_count;
                             WHILE l_msg_count > 0
                             LOOP
                                x_msg_data := FND_MSG_PUB.GET(
                                                   l_msg_index,
                                                   FND_API.G_FALSE );
                                csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
                                l_msg_index := l_msg_index + 1;
                                l_msg_count := l_msg_count - 1;
                             END LOOP;
                           RAISE FND_API.G_EXC_ERROR;
                          END IF;
			  --fix for bug 5511689:To expire non-owner accounts while expiring non-owner parties.
                          FOR exp_acct_rec IN exp_acct_csr(l_exp_pty.instance_party_id) LOOP
                            l_exp_acct_rec:=l_temp_acct_rec;
                            l_exp_acct_rec.ip_account_id := exp_acct_rec.ip_account_id;
                            l_exp_acct_rec.relationship_type_code := exp_acct_rec.relationship_type_code;
                            l_exp_acct_rec.object_version_number := exp_acct_rec.object_version_number ;
                            l_exp_acct_rec.active_end_date :=SYSDATE;
                            l_exp_acct_rec.expire_flag :=fnd_api.g_true;
                           -- Add log output for bug 7333900
                           IF (l_csi_debug_level > 0) THEN
                             csi_gen_utility_pvt.put_line('Expiring account record '||l_exp_acct_rec.ip_account_id||' of account type '||l_exp_acct_rec.relationship_type_code);
                             csi_gen_utility_pvt.put_line(' account old active_end_date : '||exp_acct_rec.active_end_date);
                             csi_gen_utility_pvt.put_line(' account new active_end_date : '||l_exp_acct_rec.active_end_date);
                             csi_gen_utility_pvt.put_line(' sysdate                     : '||SYSDATE);
                           END IF;
                           IF    l_exp_acct_rec.ip_account_id IS NOT NULL
                             AND l_exp_acct_rec.ip_account_id <> fnd_api.g_miss_num
                           THEN
                            l_exp_acct_rec.grp_call_contracts := l_grp_call_contracts;
                            csi_party_relationships_pvt.update_inst_party_account
                             ( p_api_version         => p_api_version
                              ,p_commit              => p_commit
                              ,p_init_msg_list       => p_init_msg_list
                              ,p_validation_level    => p_validation_level
                              ,p_party_account_rec   => l_exp_acct_rec
                              ,p_txn_rec             => p_txn_rec
                              ,p_oks_txn_inst_tbl    => p_oks_txn_inst_tbl
                              ,x_return_status       => x_return_status
                              ,x_msg_count           => x_msg_count
                              ,x_msg_data            => x_msg_data);

                           IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	                        l_msg_index := 1;
		                l_msg_count := x_msg_count;
				WHILE l_msg_count > 0 LOOP
					x_msg_data := FND_MSG_PUB.GET(
                                                   l_msg_index,
                                                   FND_API.G_FALSE   );
					csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
	                                l_msg_index := l_msg_index + 1;
		                        l_msg_count := l_msg_count - 1;
				END LOOP;
			        RAISE FND_API.G_EXC_ERROR;
                           END IF;
                           END IF;
                     END LOOP;
		     --end of fix 5511689
                     END LOOP;
                   END IF;
                --End addition for bug 3294748

                   l_exp_acct_rec:=l_temp_acct_rec;
                   BEGIN
                      SELECT ip_account_id,
                             relationship_type_code,
                             object_version_number
                      INTO   l_exp_acct_rec.ip_account_id,
                             l_exp_acct_rec.relationship_type_code,
                             l_exp_acct_rec.object_version_number
                      FROM   csi_ip_accounts
                      WHERE  instance_party_id=p_party_tbl(p_row).instance_party_id
                      AND    relationship_type_code ='OWNER'
                      AND    nvl(active_end_date, sysdate+1) >= sysdate;
                      l_exp_acct_rec.active_end_date :=SYSDATE;
                      l_exp_acct_rec.expire_flag :=fnd_api.g_true;
                   EXCEPTION
                     WHEN OTHERS THEN
                       NULL;
                   END;

                   IF    l_exp_acct_rec.ip_account_id IS NOT NULL
                     AND l_exp_acct_rec.ip_account_id <> fnd_api.g_miss_num
                   THEN
                            l_exp_acct_rec.grp_call_contracts := l_grp_call_contracts;
                            csi_party_relationships_pvt.update_inst_party_account
                             ( p_api_version         => p_api_version
                              ,p_commit              => p_commit
                              ,p_init_msg_list       => p_init_msg_list
                              ,p_validation_level    => p_validation_level
                              ,p_party_account_rec   => l_exp_acct_rec
                              ,p_txn_rec             => p_txn_rec
                              ,p_oks_txn_inst_tbl    => p_oks_txn_inst_tbl
                              ,x_return_status       => x_return_status
                              ,x_msg_count           => x_msg_count
                              ,x_msg_data            => x_msg_data);

                       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                           l_msg_index := 1;
                           l_msg_count := x_msg_count;
                           WHILE l_msg_count > 0 LOOP
                                 x_msg_data := FND_MSG_PUB.GET(
                                                       l_msg_index,
                                                       FND_API.G_FALSE   );
                                csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
                                l_msg_index := l_msg_index + 1;
                                l_msg_count := l_msg_count - 1;
                           END LOOP;
                             RAISE FND_API.G_EXC_ERROR;
                       END IF;
                   END IF;
                 END IF;
             END LOOP;
          END LOOP;
        -- End addition by sguthiva for bug 2307804

        END IF;
  -- Start of code addition for fixing the bug 2151750
  /* If the owner of the root of a configuration changes, the ownership should
     be inherited by all child component (children in component-of tree) having the
     same initial owner as the root.
     Here grab the root instance owner party and its owner account.
     Retreive if it has any child instances from csi_ii_relationships table of relationship_type_code
     as 'COMPONENT-OF'.
  */

      IF l_old_party_tbl.count > 0 THEN
          FOR l_old_party_row IN l_old_party_tbl.FIRST..l_old_party_tbl.LAST
          LOOP
            IF l_old_party_tbl.EXISTS(l_old_party_row) THEN
             IF l_old_party_tbl(l_old_party_row).relationship_type_code = 'OWNER' AND
                l_old_party_tbl(l_old_party_row).party_id IS NOT NULL AND
                l_old_party_tbl(l_old_party_row).party_id <> fnd_api.g_miss_num
             THEN
                -- Get Current Party record
                IF NOT(CSI_Instance_parties_vld_pvt.Get_Party_Record
                      ( l_old_party_tbl(l_old_party_row).instance_party_id,
                        l_new_curr_party_rec)) THEN
                       RAISE FND_API.G_EXC_ERROR;
                END IF;

                -- Start of code addition for fixing bug 6368172, section 3 of 5
                -- grab the owner account of the parent
                l_ip_acct_rec := l_temp_acct_rec;
                l_new_ip_acct_rec := l_temp_acct_rec;
                BEGIN
                  SELECT  instance_party_id
                          ,party_account_id
                          ,relationship_type_code
                          ,bill_to_address
                          ,ship_to_address
                          ,active_start_date
                          ,active_end_date
                          ,context
                          ,attribute1
                          ,attribute2
                          ,attribute3
                          ,attribute4
                          ,attribute5
                          ,attribute6
                          ,attribute7
                          ,attribute8
                          ,attribute9
                          ,attribute10
                          ,attribute11
                          ,attribute12
                          ,attribute13
                          ,attribute14
                          ,attribute15
                  INTO    l_ip_acct_rec.instance_party_id
                          ,l_ip_acct_rec.party_account_id
                          ,l_ip_acct_rec.relationship_type_code
                          ,l_ip_acct_rec.bill_to_address
                          ,l_ip_acct_rec.ship_to_address
                          ,l_ip_acct_rec.active_start_date
                          ,l_ip_acct_rec.active_end_date
                          ,l_ip_acct_rec.context
                          ,l_ip_acct_rec.attribute1
                          ,l_ip_acct_rec.attribute2
                          ,l_ip_acct_rec.attribute3
                          ,l_ip_acct_rec.attribute4
                          ,l_ip_acct_rec.attribute5
                          ,l_ip_acct_rec.attribute6
                          ,l_ip_acct_rec.attribute7
                          ,l_ip_acct_rec.attribute8
                          ,l_ip_acct_rec.attribute9
                          ,l_ip_acct_rec.attribute10
                          ,l_ip_acct_rec.attribute11
                          ,l_ip_acct_rec.attribute12
                          ,l_ip_acct_rec.attribute13
                          ,l_ip_acct_rec.attribute14
                          ,l_ip_acct_rec.attribute15
                  FROM    csi_ip_accounts
                  WHERE   instance_party_id = l_old_party_tbl(l_old_party_row).instance_party_id
                  AND     relationship_type_code = 'OWNER'
                  AND     SYSDATE BETWEEN nvl(active_start_date, SYSDATE-1)
                            AND nvl(active_end_date, SYSDATE+1);

                  l_new_ip_acct_rec := l_ip_acct_rec;
                EXCEPTION
                  WHEN OTHERS THEN
                     l_ip_acct_rec := l_temp_acct_rec;
                     l_new_ip_acct_rec :=l_temp_acct_rec;
                END;
                -- End of code addition for fixing bug 6368172, section 3 of 5

                -- If the retreived party records party_id has been changed then
                -- we can assume that a transfer of ownership has taken place in
                -- the above procedure.
                IF l_old_party_tbl(l_old_party_row).party_id <> l_new_curr_party_rec.party_id
                   -- Start of code addition for fixing bug 6368172, section 4 of 5
                   OR (l_old_party_tbl(l_old_party_row).party_id = l_new_curr_party_rec.party_id
                   AND l_old_parent_owner_pty_acct_id IS NOT NULL
                   AND l_old_parent_owner_pty_acct_id <> fnd_api.g_miss_num
                   AND l_old_parent_owner_pty_acct_id <> l_new_ip_acct_rec.party_account_id)
                   -- End of code addition for fixing bug 6368172, section 4 of 5
                   OR nvl(l_old_party_tbl(l_old_party_row).cascade_ownership_flag,'N')='Y' -- Added for cascade 2972082
                THEN
                -- the l_new_ip_acct_rec account needs to be passed to all the children
                -- we got an instance whose owner party, or owner account has been changed
                -- we need to grab all its children if it has any and change the
                -- ownership of them also.
                -- Here I'm grabbing the children

        -- Added for cascade bug 2972082
        IF l_old_party_tbl(l_old_party_row).instance_id IS NULL OR
           l_old_party_tbl(l_old_party_row).instance_id = fnd_api.g_miss_num
        THEN
           BEGIN
              SELECT instance_id
              INTO   l_old_party_tbl(l_old_party_row).instance_id
              FROM   csi_i_parties
              WHERE  instance_party_id=l_old_party_tbl(l_old_party_row).instance_party_id;
           EXCEPTION
             WHEN NO_DATA_FOUND THEN
              NULL;
           END;
        END IF;
        -- End addition for bug 2972082

		p_rel_query_rec.object_id := l_old_party_tbl(l_old_party_row).instance_id;
		p_rel_query_rec.relationship_type_code := 'COMPONENT-OF';
		--
                IF p_rel_query_rec.object_id IS NOT NULL AND
                   p_rel_query_rec.object_id <> FND_API.G_MISS_NUM THEN
		  csi_ii_relationships_pvt.Get_Children
		   ( p_relationship_query_rec   => p_rel_query_rec,
		     p_rel_tbl                  => l_rel_tbl,
		     p_depth                    => NULL,
		     p_active_relationship_only => FND_API.G_TRUE,
		     p_time_stamp               => FND_API.G_MISS_DATE,
		     p_get_dfs                  => FND_API.G_FALSE,
                     p_ii_relationship_level_tbl => l_ii_relationship_level_tbl,
		     x_return_status            => x_return_status,
		     x_msg_count                => x_msg_count,
		     x_msg_data                 => x_msg_data
		   );
		   --
		   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		      FND_MESSAGE.SET_NAME('CSI','CSI_API_GET_CHILDREN_ERROR');
		      FND_MSG_PUB.Add;
		      RAISE FND_API.G_EXC_ERROR;
		   END IF;
                END IF;
		 --
              IF l_rel_tbl.count > 0 THEN
                 -- FOR l_old_pty_csr IN party_csr(l_old_party_tbl(l_old_party_row).instance_id)
                 FOR j in l_rel_tbl.FIRST .. l_rel_tbl.LAST LOOP
                -- After grabbing the child instances one by one I'll call
                -- the pvt.update_inst_party_relationship for a transfer
                -- to new owner.
                -- Now grab the child instances instance_party_id
                 BEGIN
                   l_cld_party_rec := l_new_curr_party_rec;
                   l_cld_party_id  := null;
                   l_cld_party_rec.active_start_date := fnd_api.g_miss_date;
                   l_cld_party_rec.active_end_date := fnd_api.g_miss_date;
                   SELECT instance_party_id,
                          instance_id,
                          party_id,
                          object_version_number
                   INTO   l_cld_party_rec.instance_party_id,
                          l_cld_party_rec.instance_id,
                          l_cld_party_id,
                          l_cld_party_rec.object_version_number
                   FROM   csi_i_parties
                   WHERE  instance_id = l_rel_tbl(j).subject_id
                   AND    relationship_type_code = 'OWNER'
                   AND   (active_end_date IS NULL OR active_end_date > SYSDATE);

                 EXCEPTION
                    WHEN OTHERS THEN
                      l_cld_party_rec := l_temp_party_rec;
                 END;

                 BEGIN
                  SELECT party_account_id
                  INTO   l_cld_party_acct_id
                  FROM   csi_ip_accounts
                  WHERE  instance_party_id = l_cld_party_rec.instance_party_id
                  AND    relationship_type_code = 'OWNER'
                  AND    SYSDATE BETWEEN nvl(active_start_date, sysdate-1)
                                 AND     nvl(active_end_date, sysdate+1);
                 EXCEPTION
                  WHEN OTHERS THEN
                    NULL;
                 END;

                 -- The following is modified for cascade bug 2972082
                 -- to make sure parties were updated only for new party
                 -- which is different from the original party if
                 -- cascade_ownership_flag=fnd_api.g_true.
                 /*
                 IF l_cld_party_rec.instance_party_id IS NOT NULL AND
                    l_cld_party_rec.instance_party_id <> fnd_api.g_miss_num AND
                   ((l_cld_party_id = l_old_party_tbl(l_old_party_row).party_id AND
                     l_cld_party_id <> l_cld_party_rec.party_id)
                    OR
                   (l_cld_party_id <> l_old_party_tbl(l_old_party_row).party_id AND
                    l_cld_party_id <> l_cld_party_rec.party_id AND
                    nvl(l_old_party_tbl(l_old_party_row).cascade_ownership_flag,'N')='Y') -- Added for cascade 2972082
                    )
                 THEN
                 */
                 -- Start of code addition for fixing bug 6368172, section 5 of 5
                 -- Need to grab the old child account id before it gets changed
                 IF l_cld_party_rec.instance_party_id IS NOT NULL THEN
                   BEGIN
                     SELECT party_account_id
                     INTO l_old_child_owner_pty_acct_id
                     FROM csi_ip_accounts
                     WHERE instance_party_id = l_cld_party_rec.instance_party_id
                     AND relationship_type_code = 'OWNER';
                   EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                       l_old_child_owner_pty_acct_id := NULL;
                   END;
                 END IF;
                 IF l_cld_party_rec.instance_party_id IS NOT NULL AND
                    l_cld_party_rec.instance_party_id <> fnd_api.g_miss_num AND
                   ((l_cld_party_id = l_old_party_tbl(l_old_party_row).party_id AND
                     l_cld_party_id <> l_cld_party_rec.party_id)
                    OR
                    (l_cld_party_id = l_old_party_tbl(l_old_party_row).party_id AND
                     l_cld_party_id = l_cld_party_rec.party_id AND
                     l_old_parent_owner_pty_acct_id IS NOT NULL AND
                     l_old_parent_owner_pty_acct_id <> fnd_api.g_miss_num AND
                     l_old_child_owner_pty_acct_id IS NOT NULL AND
                     l_old_child_owner_pty_acct_id <> fnd_api.g_miss_num AND
                     l_old_child_owner_pty_acct_id = l_old_parent_owner_pty_acct_id AND
                     l_old_child_owner_pty_acct_id <> l_new_ip_acct_rec.party_account_id)
                    OR
                   (l_cld_party_id <> l_old_party_tbl(l_old_party_row).party_id AND
                    l_cld_party_id <> l_cld_party_rec.party_id AND
                    nvl(l_old_party_tbl(l_old_party_row).cascade_ownership_flag,'N')='Y') -- Added for cascade 2972082
                    )
                 THEN
                 -- End of code addition for fixing bug 6368172, section 5 of 5

                   csi_party_relationships_pvt.update_inst_party_relationship
                    ( p_api_version      => p_api_version
                     ,p_commit           => p_commit
                     ,p_init_msg_list    => p_init_msg_list
                     ,p_validation_level => p_validation_level
                     ,p_party_rec        => l_cld_party_rec
                     ,p_txn_rec          => p_txn_rec
                     ,x_return_status    => x_return_status
                     ,x_msg_count        => x_msg_count
                     ,x_msg_data         => x_msg_data  ) ;

                     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                       l_msg_index := 1;
                       l_msg_count := x_msg_count;
                       WHILE l_msg_count > 0 LOOP
                             x_msg_data := FND_MSG_PUB.GET(
                                                  l_msg_index,
                                                  FND_API.G_FALSE );
                             csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
                             l_msg_index := l_msg_index + 1;
                             l_msg_count := l_msg_count - 1;
                       END LOOP;
                       RAISE FND_API.G_EXC_ERROR;
                     END IF;

                     --added may15
        -- Added by sguthiva for bug 2307804
        -- The following code has wrritten specifically for expiring the ownership of
        -- an external party during the transfer of ownership from external to internal.
                  IF  l_cld_party_rec.party_id = l_internal_party_id
                  THEN
                   -- Adding for bug 3294748
                   -- Wrote the following code to expire all non-owner parties and its contacts (if any)
                   -- in the case of ext-to-int ownership transfer, however we do not expire non-owner accounts.
                   IF l_cld_party_rec.relationship_type_code='OWNER'
                   THEN
                     FOR l_exp_pty IN exp_pty_csr(l_cld_party_rec.instance_id)
                     LOOP
                       l_exp_party_rec:= l_temp_party_rec;
                       l_exp_party_rec.instance_id:= l_cld_party_rec.instance_id;
                       l_exp_party_rec.instance_party_id := l_exp_pty.instance_party_id;
                       l_exp_party_rec.relationship_type_code := l_exp_pty.relationship_type_code;
                       l_exp_party_rec.object_version_number := l_exp_pty.object_version_number;
                       -- Bug 3804960
                       -- srramakr Need to use the same the date used by the item instance
                       IF p_txn_rec.src_txn_creation_date IS NULL OR
                          p_txn_rec.src_txn_creation_date = FND_API.G_MISS_DATE THEN
                          l_exp_party_rec.active_end_date := sysdate;
                       ELSE
                          l_exp_party_rec.active_end_date := p_txn_rec.src_txn_creation_date;
                       END IF;
                       -- End of 3804960
                        csi_party_relationships_pvt.update_inst_party_relationship
                         ( p_api_version      => p_api_version
                          ,p_commit           => p_commit
                          ,p_init_msg_list    => p_init_msg_list
                          ,p_validation_level => p_validation_level
                          ,p_party_rec        => l_exp_party_rec
                          ,p_txn_rec          => p_txn_rec
                          ,x_return_status    => x_return_status
                          ,x_msg_count        => x_msg_count
                          ,x_msg_data         => x_msg_data  ) ;

                          IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                             l_msg_index := 1;
                             l_msg_count := x_msg_count;
                             WHILE l_msg_count > 0
                             LOOP
                                x_msg_data := FND_MSG_PUB.GET(
                                                   l_msg_index,
                                                   FND_API.G_FALSE );
                                csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
                                l_msg_index := l_msg_index + 1;
                                l_msg_count := l_msg_count - 1;
                             END LOOP;
                           RAISE FND_API.G_EXC_ERROR;
                          END IF;
                     END LOOP;
                   END IF;
                   --End addition for bug 3294748
                   l_exp_acct_rec:=l_temp_acct_rec;
                   BEGIN
                      SELECT ip_account_id,
                             relationship_type_code,
                             object_version_number
                      INTO   l_exp_acct_rec.ip_account_id,
                             l_exp_acct_rec.relationship_type_code,
                             l_exp_acct_rec.object_version_number
                      FROM   csi_ip_accounts
                      WHERE  instance_party_id=l_cld_party_rec.instance_party_id
                      AND    relationship_type_code ='OWNER';
                     -- Bug 3804960
                      -- srramakr Need to use the same the date used by the item instance
                      IF p_txn_rec.src_txn_creation_date IS NULL OR
                         p_txn_rec.src_txn_creation_date = FND_API.G_MISS_DATE THEN
                         l_exp_acct_rec.active_end_date := sysdate;
                      ELSE
                         l_exp_acct_rec.active_end_date := p_txn_rec.src_txn_creation_date;
                      END IF;
                      -- End of 3804960
                      l_exp_acct_rec.expire_flag :=fnd_api.g_true;
                   EXCEPTION
                     WHEN OTHERS THEN
                       NULL;
                   END;

                   IF    l_exp_acct_rec.ip_account_id IS NOT NULL
                     AND l_exp_acct_rec.ip_account_id <> fnd_api.g_miss_num
                   THEN
                            l_exp_acct_rec.grp_call_contracts := l_grp_call_contracts;
                            csi_party_relationships_pvt.update_inst_party_account
                             ( p_api_version         => p_api_version
                              ,p_commit              => p_commit
                              ,p_init_msg_list       => p_init_msg_list
                              ,p_validation_level    => p_validation_level
                              ,p_party_account_rec   => l_exp_acct_rec
                              ,p_txn_rec             => p_txn_rec
                              ,p_oks_txn_inst_tbl => p_oks_txn_inst_tbl
                              ,x_return_status       => x_return_status
                              ,x_msg_count           => x_msg_count
                              ,x_msg_data            => x_msg_data);

                       IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                           l_msg_index := 1;
                           l_msg_count := x_msg_count;
                           WHILE l_msg_count > 0 LOOP
                                 x_msg_data := FND_MSG_PUB.GET(
                                                       l_msg_index,
                                                       FND_API.G_FALSE   );
                                csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
                                l_msg_index := l_msg_index + 1;
                                l_msg_count := l_msg_count - 1;
                           END LOOP;
                             RAISE FND_API.G_EXC_ERROR;
                       END IF;
                   END IF;
                  END IF;
                 -- End addition by sguthiva for bug 2307804
                  IF  l_cld_party_rec.party_id <> l_internal_party_id
                  THEN
                   IF l_ip_acct_rec.instance_party_id IS NOT NULL AND
                      l_ip_acct_rec.instance_party_id <> fnd_api.g_miss_num
                   THEN
                   l_ip_acct_rec:=l_new_ip_acct_rec; -- added for 2608706
                   l_ip_acct_rec.instance_party_id := l_cld_party_rec.instance_party_id;
                   l_ip_acct_rec.ip_account_id     := fnd_api.g_miss_num;
                   -- srramakr Bug 3621181 need to cascade Bill_to and Ship_to address to the children
                  -- l_ip_acct_rec.bill_to_address   := fnd_api.g_miss_num;
                  -- l_ip_acct_rec.ship_to_address   := fnd_api.g_miss_num;
                   l_ip_acct_rec.active_start_date := fnd_api.g_miss_date; -- added for 2608706
                   l_ip_acct_rec.active_end_date   := fnd_api.g_miss_date; -- added for 2608706
                   l_ip_acct_rec.grp_call_contracts := l_grp_call_contracts;
                    -- Added the following code for bug 2972082
                    IF   nvl(l_old_party_tbl(l_old_party_row).cascade_ownership_flag,'N')='Y'
                     AND l_cld_party_id <> l_cld_party_rec.party_id
                     AND l_cld_party_id <> l_internal_party_id
                    THEN
                      l_ip_acct_rec.cascade_ownership_flag:='Y';
                    END IF;
                    -- End of addition for bug 2972082
                    -- Need to pass the system_id for components also if the Xfer of ownership is
                    -- initiated from xfer of system. This will be true if both parent and child instances
                    -- belong to the same system.
                    l_ip_acct_rec.system_id := fnd_api.g_miss_num;
                    --
                    IF p_party_account_tbl.EXISTS(1) AND
                       p_party_account_tbl(1).system_id IS NOT NULL AND
                       p_party_account_tbl(1).system_id <> FND_API.G_MISS_NUM AND
                       NVL(p_party_account_tbl(1).relationship_type_code,FND_API.G_MISS_CHAR) = 'OWNER' THEN
                       Begin
                          select system_id
                          into l_ip_acct_rec.system_id
                          from csi_item_instances
                          where instance_id = l_rel_tbl(j).subject_id
                          and   nvl(system_id,fnd_api.g_miss_num) = p_party_account_tbl(1).system_id;
                       Exception
                          when no_data_found then
                             l_ip_acct_rec.system_id := fnd_api.g_miss_num;
                       End;
                    END IF;
                   csi_party_relationships_pvt.create_inst_party_account
                    ( p_api_version         => p_api_version
                     ,p_commit              => p_commit
                     ,p_init_msg_list       => p_init_msg_list
                     ,p_validation_level    => p_validation_level
                     ,p_party_account_rec   => l_ip_acct_rec
                     ,p_txn_rec             => p_txn_rec
                     ,x_return_status       => x_return_status
                     ,x_msg_count           => x_msg_count
                     ,x_msg_data            => x_msg_data
                     ,p_inst_party_tbl      => l_inst_party_tbl
                     ,p_acct_rel_type_tbl   => l_acct_rel_type_tbl
                     ,p_site_use_tbl        => l_site_use_tbl
                     ,p_account_count_rec   => l_account_count_rec
                     ,p_oks_txn_inst_tbl => p_oks_txn_inst_tbl
                   );

                     IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                       l_msg_index := 1;
                       l_msg_count := x_msg_count;
                       WHILE l_msg_count > 0 LOOP
                             x_msg_data := FND_MSG_PUB.GET(
                                                  l_msg_index,
                                                  FND_API.G_FALSE );
                             csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
                             l_msg_index := l_msg_index + 1;
                             l_msg_count := l_msg_count - 1;
                       END LOOP;
                       RAISE FND_API.G_EXC_ERROR;
                     END IF;
                   END IF;
                  END IF;
                     -- End commentation by sguthiva for bug 2307804
                 END IF;

                 END LOOP;
               END IF; -- l_rel_tbl count check

                END IF;
             END IF;
            END IF;
          END LOOP;
      END IF;
  -- End of code addition for fixing the bug 2151750

  -- code written by sk on 12/06/01 for fixing TRF bug 2133944
        -- End of API body


        -- Standard check of p_commit.
        IF FND_API.To_Boolean( p_commit ) THEN
                COMMIT WORK;
        END IF;

        /***** srramakr commented for bug # 3304439
        -- Check for the profile option and disable the trace
        IF (l_flag = 'Y') THEN
            dbms_session.set_sql_trace(false);
        END IF;
        -- End disable trace
        ****/

        -- Standard call to get message count and if count is  get message info.
        FND_MSG_PUB.Count_And_Get
                (p_count        =>      x_msg_count ,
                 p_data         =>      x_msg_data     );
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO update_inst_party_rel_pub;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count   =>      x_msg_count,
                        p_data    =>      x_msg_data    );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO update_inst_party_rel_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                ( p_count     =>      x_msg_count,
                  p_data      =>      x_msg_data  );
        WHEN OTHERS THEN
                ROLLBACK TO update_inst_party_rel_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF FND_MSG_PUB.Check_Msg_Level
                     (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                   FND_MSG_PUB.Add_Exc_Msg
                    ( g_pkg_name, l_api_name );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (  p_count   =>      x_msg_count,
                   p_data    =>      x_msg_data   );
END update_inst_party_relationship ;


/*-------------------------------------------------------------*/
/* Procedure name:  Expire_inst_party_relationship             */
/* Description :  Procedure used to  expire an existing        */
/*                instance -party relationships                */
/*-------------------------------------------------------------*/

PROCEDURE expire_inst_party_relationship
 (    p_api_version                 IN     NUMBER
     ,p_commit                      IN     VARCHAR2
     ,p_init_msg_list               IN     VARCHAR2
     ,p_validation_level            IN     NUMBER
     ,p_instance_party_tbl          IN     csi_datastructures_pub.party_tbl
     ,p_txn_rec                     IN OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status               OUT NOCOPY    VARCHAR2
     ,x_msg_count                   OUT NOCOPY    NUMBER
     ,x_msg_data                    OUT NOCOPY    VARCHAR2
   ) IS
      l_api_name      CONSTANT VARCHAR2(30)   := 'EXPIRE_INST_PARTY_RELATIONSHIP';
      l_api_version   CONSTANT NUMBER         := 1.0;
      l_csi_debug_level        NUMBER;
      l_party_rec              csi_datastructures_pub.party_rec;
      l_msg_index              NUMBER;
      l_msg_count              NUMBER;
      l_line_count             NUMBER;
      l_flag                   VARCHAR2(1)  :='N';

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT  expire_inst_party_rel_pub;

     -- Check for freeze_flag in csi_install_parameters is set to 'Y'

     csi_utility_grp.check_ib_active;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (    l_api_version           ,
                                                p_api_version           ,
                                                l_api_name              ,
                                                g_pkg_name              )
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- Check the profile option CSI_DEBUG_LEVEL for debug message reporting
        l_csi_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

        -- If CSI_DEBUG_LEVEL = 1 then dump the procedure name
        IF (l_csi_debug_level > 0) THEN
            csi_gen_utility_pvt.put_line( 'expire_inst_party_relationship');
        END IF;

        -- If the debug level = 2 then dump all the parameters values.
        IF (l_csi_debug_level > 1) THEN
             csi_gen_utility_pvt.put_line( 'expire_inst_party_relationship:'  ||
                                                         p_api_version      ||'-'||
                                                         p_commit           ||'-'||
                                                         p_init_msg_list    ||'-'||
                                                         p_validation_level      );
               -- Dump the records in the log file
              csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);
              csi_gen_utility_pvt.dump_party_tbl(p_instance_party_tbl);
        END IF;

        /***** srramakr commented for bug # 3304439
        -- Check for the profile option and enable trace
        l_flag:=csi_gen_utility_pvt.enable_trace(l_trace_flag => l_flag);
        -- End enable trace
        ****/

        -- Start API body
        --
        IF p_instance_party_tbl.count > 0 THEN
           FOR l_count IN p_instance_party_tbl.FIRST..p_instance_party_tbl.LAST LOOP
            IF p_instance_party_tbl.EXISTS(l_count) THEN
                csi_party_relationships_pvt.expire_inst_party_relationship
                   (  p_api_version       => p_api_version,
                      p_commit            => p_commit,
                      p_init_msg_list     => p_init_msg_list,
                      p_validation_level  => p_validation_level,
                      p_instance_party_rec=> p_instance_party_tbl(l_count),
                      p_txn_rec           => p_txn_rec,
                      x_return_status     => x_return_status ,
                      x_msg_count         => x_msg_count ,
                      x_msg_data          => x_msg_data               ) ;

                IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                        l_msg_index := 1;
                   l_msg_count := x_msg_count;
                   WHILE l_msg_count > 0 LOOP
                         x_msg_data := FND_MSG_PUB.GET(
                                                        l_msg_index,
                                                        FND_API.G_FALSE );
                     csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
                         l_msg_index := l_msg_index + 1;
                         l_msg_count := l_msg_count - 1;
                   END LOOP;
                   RAISE FND_API.G_EXC_ERROR;
                END IF;
           END IF;
          END LOOP;
        END IF;
        --
        -- End of API body

        -- Standard check of p_commit.
        IF FND_API.To_Boolean( p_commit ) THEN
                COMMIT WORK;
        END IF;

        /***** srramakr commented for bug # 3304439
        -- Check for the profile option and disable the trace
        IF (l_flag = 'Y') THEN
            dbms_session.set_sql_trace(false);
        END IF;
        -- End disable trace
        ****/

        -- Standard call to get message count and if count is  get message info.
        FND_MSG_PUB.Count_And_Get
                (p_count        =>      x_msg_count ,
                 p_data         =>      x_msg_data   );
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO expire_inst_party_rel_pub;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count         =>      x_msg_count,
                        p_data          =>      x_msg_data   );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO expire_inst_party_rel_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (  p_count     =>      x_msg_count,
                   p_data      =>      x_msg_data  );

        WHEN OTHERS THEN
                ROLLBACK TO expire_inst_party_relationship;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF FND_MSG_PUB.Check_Msg_Level
                     (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                   FND_MSG_PUB.Add_Exc_Msg
                    ( g_pkg_name, l_api_name );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (  p_count    =>      x_msg_count,
                   p_data     =>      x_msg_data  );

END  expire_inst_party_relationship;

/*---------------------------------------------------------*/
/* Procedure name:  Get_inst_party_account                 */
/* Description :  Procedure used to  get information about */
/*            the accounts related to an instance-party    */
/*---------------------------------------------------------*/

PROCEDURE get_inst_party_accounts
 (    p_api_version             IN  NUMBER
     ,p_commit                  IN  VARCHAR2
     ,p_init_msg_list           IN  VARCHAR2
     ,p_validation_level        IN  NUMBER
     ,p_account_query_rec       IN  csi_datastructures_pub.party_account_query_rec
     ,p_resolve_id_columns      IN  VARCHAR2
     ,p_time_stamp              IN  DATE
     ,x_account_header_tbl      OUT NOCOPY csi_datastructures_pub.party_account_header_tbl
     ,x_return_status           OUT NOCOPY VARCHAR2
     ,x_msg_count               OUT NOCOPY NUMBER
     ,x_msg_data                OUT NOCOPY VARCHAR2
   ) IS

      l_api_name      CONSTANT VARCHAR2(30)   := 'GET_INST_PARTY_ACCOUNT';
      l_api_version   CONSTANT NUMBER              := 1.0;
      l_csi_debug_level        NUMBER;
      l_instance_party_account_id      NUMBER;
      l_party_account_tbl      csi_datastructures_pub.party_account_tbl;
      l_account_header_tbl     csi_datastructures_pub.party_account_header_tbl;
      l_line_count             NUMBER;
      l_msg_index              NUMBER;
      l_count                  NUMBER := 0;
      l_where_clause           VARCHAR2(2000) ;
      l_get_acct_cursor_id     NUMBER ;
      l_rows_processed         NUMBER ;
      l_flag                   VARCHAR2(1)  :='N';
      l_party_account_rec      csi_datastructures_pub.party_account_header_rec;
      l_select_stmt            VARCHAR2(2000) := ' SELECT ip_account_id , instance_party_id, party_account_id, '||
                                   ' relationship_type_code, active_start_date, active_end_date,context , attribute1, '||
                                   ' attribute2, attribute3, attribute4, attribute5, attribute6, attribute7,attribute8, '||
                                   ' attribute9, attribute10,attribute11, attribute12,attribute13,attribute14,attribute15, '||
                                   ' object_version_number, bill_to_address, ship_to_address from csi_ip_accounts  ';


BEGIN
        -- Standard Start of API savepoint
        -- SAVEPOINT  get_inst_party_acct_pub;

     -- Check for freeze_flag in csi_install_parameters is set to 'Y'

     csi_utility_grp.check_ib_active;


        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (    l_api_version           ,
                                                p_api_version           ,
                                                l_api_name              ,
                                                g_pkg_name              )
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- Check the profile option CSI_DEBUG_LEVEL for debug message reporting
        l_csi_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

        -- If CSI_DEBUG_LEVEL = 1 then dump the procedure name
        IF (l_csi_debug_level > 0) THEN
            csi_gen_utility_pvt.put_line( 'get_inst_party_accounts');
        END IF;

        -- If the debug level = 2 then dump all the parameters values.
        IF (l_csi_debug_level > 1) THEN

             csi_gen_utility_pvt.put_line( 'get_inst_party_account:' ||
                                           p_api_version           ||'-'||
                                           p_commit                ||'-'||
                                           p_init_msg_list         ||'-'||
                                           p_validation_level      ||'-'||
                                           p_time_stamp                  );
            -- Dump the account query records
            csi_gen_utility_pvt.dump_account_query_rec(p_account_query_rec);

        END IF;

        /***** srramakr commented for bug # 3304439
        -- Check for the profile option and enable trace
        l_flag:=csi_gen_utility_pvt.enable_trace(l_trace_flag => l_flag);
        -- End enable trace
        ****/

        -- Start API body
        --
        IF    (p_account_query_rec.ip_account_id      = FND_API.G_MISS_NUM)
          AND (p_account_query_rec.instance_party_id  = FND_API.G_MISS_NUM)
          AND (p_account_query_rec.party_account_id   = FND_API.G_MISS_NUM)
          AND (p_account_query_rec.relationship_type_code  = FND_API.G_MISS_CHAR) THEN

           FND_MESSAGE.Set_Name('CSI', 'CSI_API_INVALID_PARAMETERS');
           FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

       -- Generate the where clause
       csi_party_relationships_pvt.Gen_Acct_Where_Clause
       (   p_pty_acct_query_rec     =>  p_account_query_rec,
           x_where_clause           =>  l_where_clause    );

       -- Build the select statement
       l_select_stmt := l_select_stmt || ' where '||l_where_clause;

       -- Open the cursor
       l_get_acct_cursor_id := dbms_sql.open_cursor;

       --Parse the select statement
       dbms_sql.parse(l_get_acct_cursor_id, l_select_stmt , dbms_sql.native);

       -- Bind the variables
       csi_party_relationships_pvt.Bind_acct_variable(p_account_query_rec, l_get_acct_cursor_id);

       -- Define output variables
       csi_party_relationships_pvt.Define_Acct_Columns(l_get_acct_cursor_id);

        -- execute the select statement
       l_rows_processed := dbms_sql.execute(l_get_acct_cursor_id);

       LOOP
       EXIT WHEN DBMS_SQL.FETCH_ROWS(l_get_acct_cursor_id) = 0;
             csi_party_relationships_pvt.Get_acct_Column_Values(l_get_acct_cursor_id, l_party_account_rec);
             l_count := l_count + 1;
             x_account_header_tbl(l_count) := l_party_account_rec;
       END LOOP;

       -- Close the cursor
       DBMS_SQL.CLOSE_CURSOR(l_get_acct_cursor_id);

       IF ((p_time_stamp IS NOT NULL) AND (p_time_stamp <> FND_API.G_MISS_DATE)) THEN
          IF p_time_stamp <= sysdate THEN
             -- Contruct from the history if p_time_stamp is less than sysdate
             csi_party_relationships_pvt.Construct_acct_from_hist(x_account_header_tbl, p_time_stamp);
         ELSE
            FND_MESSAGE.Set_Name('CSI', 'CSI_API_INVALID_HIST_PARAMS');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
       END IF;

       -- foreign key resolution for the id columns
       IF p_resolve_id_columns = fnd_api.g_true THEN
          IF x_account_header_tbl.count > 0 THEN
             l_account_header_tbl := x_account_header_tbl;
             csi_party_relationships_pvt.Resolve_id_columns(l_account_header_tbl);

             x_account_header_tbl := l_account_header_tbl;
          END IF;
       END IF;

       --
       -- End of API body

       -- Standard check of p_commit.
       /*
       IF FND_API.To_Boolean( p_commit ) THEN
                COMMIT WORK;
       END IF;
       */

       /***** srramakr commented for bug # 3304439
       -- Check for the profile option and disable the trace
       IF (l_flag = 'Y') THEN
            dbms_session.set_sql_trace(false);
       END IF;
       -- End disable trace
       ****/

       -- Standard call to get message count and if count is  get message info.
       FND_MSG_PUB.Count_And_Get
                (p_count        =>      x_msg_count ,
                 p_data         =>      x_msg_data  );
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
              --  ROLLBACK TO get_inst_party_acct_pub;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                ( p_count     =>      x_msg_count,
                  p_data      =>      x_msg_data  );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              --  ROLLBACK TO get_inst_party_acct_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (  p_count     =>      x_msg_count,
                   p_data      =>      x_msg_data    );
       WHEN OTHERS THEN
                IF dbms_sql.is_open(l_get_acct_cursor_id) then
                   dbms_sql.close_cursor(l_get_acct_cursor_id);
                END IF;
              --   ROLLBACK TO get_inst_party_acct_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF FND_MSG_PUB.Check_Msg_Level
                     (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                   FND_MSG_PUB.Add_Exc_Msg
                    ( g_pkg_name, l_api_name );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (  p_count     =>      x_msg_count,
                   p_data      =>      x_msg_data      );
END get_inst_party_accountS ;

/*----------------------------------------------------------*/
/* Procedure name:  Create_inst_party_account               */
/* Description :  Procedure used to  create new             */
/*                instance-party account relationships      */
/*----------------------------------------------------------*/

PROCEDURE create_inst_party_account
 (    p_api_version         IN      NUMBER
     ,p_commit              IN      VARCHAR2
     ,p_init_msg_list       IN      VARCHAR2
     ,p_validation_level    IN      NUMBER
     ,p_party_account_tbl   IN  OUT NOCOPY csi_datastructures_pub.party_account_tbl
     ,p_txn_rec             IN  OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status       OUT NOCOPY     VARCHAR2
     ,x_msg_count           OUT NOCOPY     NUMBER
     ,x_msg_data            OUT NOCOPY     VARCHAR2
   ) IS

     l_api_name      CONSTANT VARCHAR2(30)   := 'CREATE_INST_PARTY_ACCOUNT';
     l_api_version   CONSTANT NUMBER             := 1.0;
     l_csi_debug_level        NUMBER;
     l_party_account_rec      csi_datastructures_pub.party_account_rec;
     l_msg_index              NUMBER;
     l_msg_count              NUMBER;
     l_line_count             NUMBER;
     l_flag                   VARCHAR2(1)  :='N';
     l_inst_party_tbl         csi_party_relationships_pvt.inst_party_tbl;
     l_acct_rel_type_tbl      csi_party_relationships_pvt.acct_rel_type_tbl;
     l_site_use_tbl           csi_party_relationships_pvt.site_use_tbl;
     l_account_count_rec      csi_party_relationships_pvt.account_count_rec;
     --
     px_oks_txn_inst_tbl      oks_ibint_pub.txn_instance_tbl;

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT  create_inst_party_acct_pub;

     -- Check for freeze_flag in csi_install_parameters is set to 'Y'

     csi_utility_grp.check_ib_active;


        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (    l_api_version           ,
                                                p_api_version           ,
                                                l_api_name              ,
                                                g_pkg_name              )
        THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- Check the profile option CSI_DEBUG_LEVEL for debug message reporting
        l_csi_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

        -- If CSI_DEBUG_LEVEL = 1 then dump the procedure name
        IF (l_csi_debug_level > 0) THEN
            csi_gen_utility_pvt.put_line( 'create_inst_party_account');
        END IF;

        -- If the debug level = 2 then dump all the parameters values.
        IF (l_csi_debug_level > 1) THEN
                csi_gen_utility_pvt.put_line( 'create_inst_party_account:'||
                                                p_api_version           ||'-'||
                                                p_commit                ||'-'||
                                                p_init_msg_list               );
               -- Dump the records in the log file
               csi_gen_utility_pvt.dump_party_account_tbl(p_party_account_tbl);
               csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);
        END IF;

        /***** srramakr commented for bug # 3304439
        -- Check for the profile option and enable trace
        l_flag:=csi_gen_utility_pvt.enable_trace(l_trace_flag => l_flag);
        -- End enable trace
        ****/

        -- Start API body
        --
        -- Check if the table is not empty
        IF p_party_account_tbl.count > 0 THEN
           FOR l_count IN p_party_account_tbl.FIRST..p_party_account_tbl.LAST LOOP
               IF p_party_account_tbl.EXISTS(l_count) THEN

                 -- Call Private package to validate and create party accounts
                 csi_party_relationships_pvt.create_inst_party_account
                 ( p_api_version         => p_api_version
                  ,p_commit              => p_commit
                  ,p_init_msg_list       => p_init_msg_list
                  ,p_validation_level    => p_validation_level
                  ,p_party_account_rec   => p_party_account_tbl(l_count)
                  ,p_txn_rec             => p_txn_rec
                  ,x_return_status       => x_return_status
                  ,x_msg_count           => x_msg_count
                  ,x_msg_data            => x_msg_data
                  ,p_inst_party_tbl      => l_inst_party_tbl
                  ,p_acct_rel_type_tbl   => l_acct_rel_type_tbl
                  ,p_site_use_tbl        => l_site_use_tbl
                  ,p_account_count_rec   => l_account_count_rec
                  ,p_oks_txn_inst_tbl    => px_oks_txn_inst_tbl
                );

                  IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                        l_msg_index := 1;
                          l_msg_count := x_msg_count;
                          WHILE l_msg_count > 0 LOOP
                                  x_msg_data := FND_MSG_PUB.GET(
                                                          l_msg_index,
                                              FND_API.G_FALSE   );
                        csi_gen_utility_pvt.put_line( 'message data = '||x_msg_data);
                          l_msg_index := l_msg_index + 1;
                  l_msg_count := l_msg_count - 1;
                  END LOOP;
                        RAISE FND_API.G_EXC_ERROR;
                  END IF;
              END IF;
          END LOOP;
        END IF;
        --
        -- End of API body

        -- Standard check of p_commit.
        IF FND_API.To_Boolean( p_commit ) THEN
                COMMIT WORK;
        END IF;

        /***** srramakr commented for bug # 3304439
        -- Check for the profile option and disable the trace
        IF (l_flag = 'Y') THEN
            dbms_session.set_sql_trace(false);
        END IF;
        -- End disable trace
        ****/

        -- Standard call to get message count and if count is  get message info.
        FND_MSG_PUB.Count_And_Get
              (p_count   =>      x_msg_count ,
               p_data    =>      x_msg_data  );
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO create_inst_party_acct_pub;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (   p_count     =>     x_msg_count,
                    p_data      =>     x_msg_data   );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO create_inst_party_acct_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                ( p_count     =>    x_msg_count,
                  p_data      =>    x_msg_data  );
        WHEN OTHERS THEN
                ROLLBACK TO create_inst_party_acct_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF FND_MSG_PUB.Check_Msg_Level
                     (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                   FND_MSG_PUB.Add_Exc_Msg
                    ( g_pkg_name, l_api_name );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (  p_count   =>      x_msg_count,
                   p_data    =>      x_msg_data   );
END create_inst_party_account;

/*------------------------------------------------------------*/
/* Procedure name:  Update_inst_party_account                 */
/* Description :  Procedure used to update the existing       */
/*                instance-party account relationships        */
/*------------------------------------------------------------*/

PROCEDURE update_inst_party_account
 (    p_api_version                 IN     NUMBER
     ,p_commit                      IN     VARCHAR2
     ,p_init_msg_list               IN     VARCHAR2
     ,p_validation_level            IN     NUMBER
     ,p_party_account_tbl           IN     csi_datastructures_pub.party_account_tbl
     ,p_txn_rec                     IN OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status               OUT NOCOPY    VARCHAR2
     ,x_msg_count                   OUT NOCOPY    NUMBER
     ,x_msg_data                    OUT NOCOPY    VARCHAR2
   ) IS
/***    CURSOR party_account_csr (p_ins_pty_id IN NUMBER) IS
     SELECT subject_id
     FROM   csi_ii_relationships
     WHERE  relationship_type_code = 'COMPONENT-OF'
     START WITH object_id =  (SELECT instance_id+0
                              FROM   csi_i_parties
                              WHERE  instance_party_id = p_ins_pty_id
                              AND    relationship_type_code = 'OWNER'
                              AND    (active_end_date IS NULL OR active_end_date > sysdate)
                             )
     CONNECT BY object_id = PRIOR subject_id; ***/

     l_api_name      CONSTANT VARCHAR2(30)   := 'UPDATE_INST_PARTY_ACCOUNT';
     l_api_version   CONSTANT NUMBER         := 1.0;
     l_csi_debug_level        NUMBER;
     l_party_account_rec      csi_datastructures_pub.party_account_rec;
     l_msg_index              NUMBER;
     l_msg_count              NUMBER;
     l_line_count             NUMBER;
     l_flag                   VARCHAR2(1)  :='N';
     l_party_account_tbl      csi_datastructures_pub.party_account_tbl := p_party_account_tbl;
     l_temp_account_tbl       csi_datastructures_pub.party_account_tbl;
     old_party_account_id     NUMBER;
     l_acct_row               NUMBER :=1;
     old_party_id             NUMBER;
     l_party_id               NUMBER;
     p_rel_query_rec          csi_datastructures_pub.relationship_query_rec;
     l_rel_tbl                csi_datastructures_pub.ii_relationship_tbl;
     l_object_id              NUMBER;
     l_ii_relationship_level_tbl csi_ii_relationships_pvt.ii_relationship_level_tbl;
     px_oks_txn_inst_tbl      oks_ibint_pub.txn_instance_tbl;
BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT  update_inst_party_acct_pub;

     -- Check for freeze_flag in csi_install_parameters is set to 'Y'

     csi_utility_grp.check_ib_active;


        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (    l_api_version   ,
                                                p_api_version   ,
                                                l_api_name      ,
                                                g_pkg_name      )
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- Check the profile option CSI_DEBUG_LEVEL for debug message reporting
        l_csi_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

        -- If CSI_DEBUG_LEVEL = 1 then dump the procedure name
        IF (l_csi_debug_level > 0) THEN
            csi_gen_utility_pvt.put_line( 'update_inst_party_account');
        END IF;

        -- If the debug level = 2 then dump all the parameters values.
        IF (l_csi_debug_level > 1) THEN
                csi_gen_utility_pvt.put_line( 'update_inst_party_account:'||
                                                p_api_version           ||'-'||
                                                p_commit                ||'-'||
                                                p_init_msg_list               );
                -- Dump the records in the log file
               csi_gen_utility_pvt.dump_party_account_tbl(p_party_account_tbl);
               csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);
        END IF;

        /***** srramakr commented for bug # 3304439
        -- Check for the profile option and enable trace
        l_flag:=csi_gen_utility_pvt.enable_trace(l_trace_flag => l_flag);
        -- End enable trace
        ****/

        -- Start API body
        --
        -- Check if the table is not empty
        IF p_party_account_tbl.count > 0 THEN
           FOR l_count IN p_party_account_tbl.FIRST..p_party_account_tbl.LAST LOOP
             IF p_party_account_tbl.EXISTS(l_count) THEN
               IF p_party_account_tbl(l_count).ip_account_id IS NOT NULL AND
                  p_party_account_tbl(l_count).ip_account_id <> fnd_api.g_miss_num
               THEN
                BEGIN
                   SELECT acct.ip_account_id,
                          acct.party_account_id,
                          pty.party_id
                   INTO   l_temp_account_tbl(l_acct_row).ip_account_id,
                          l_temp_account_tbl(l_acct_row).party_account_id,
                          l_temp_account_tbl(l_acct_row).attribute1
                   FROM   csi_ip_accounts acct,
                          csi_i_parties   pty
                   WHERE  acct.ip_account_id = p_party_account_tbl(l_count).ip_account_id
                   AND    acct.instance_party_id = pty.instance_party_id;

                   l_acct_row := l_acct_row+1;
                EXCEPTION
                  WHEN OTHERS THEN
                    NULL;
                END;
               END IF;
              -- dbms_output.put_line('PUB: caling update_inst_party_account');
               csi_party_relationships_pvt.update_inst_party_account
                (     p_api_version         => p_api_version
                     ,p_commit              => p_commit
                     ,p_init_msg_list       => p_init_msg_list
                     ,p_validation_level    => p_validation_level
                     ,p_party_account_rec   => p_party_account_tbl(l_count)
                     ,p_txn_rec             => p_txn_rec
                     ,p_oks_txn_inst_tbl    => px_oks_txn_inst_tbl
                     ,x_return_status       => x_return_status
                     ,x_msg_count           => x_msg_count
                     ,x_msg_data            => x_msg_data);

                IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                         l_msg_index := 1;
                    l_msg_count := x_msg_count;
                    WHILE l_msg_count > 0 LOOP
                         x_msg_data := FND_MSG_PUB.GET(
                                              l_msg_index,
                                                      FND_API.G_FALSE   );
                        csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
                        l_msg_index := l_msg_index + 1;
                        l_msg_count := l_msg_count - 1;
                    END LOOP;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
             END IF;
          END LOOP;
        END IF;

        -- If the owner account (party_account_id) has been changed then if the Instance has any children
        -- then all the children (in COMPONENT-OF relationship_type_code) has to get the same party_account_id.
        -- Start of fix for bug 2151750
        IF l_party_account_tbl.count > 0
        THEN
           FOR l_old_party_row IN l_party_account_tbl.FIRST..l_party_account_tbl.LAST
           LOOP
            IF l_party_account_tbl.EXISTS(l_old_party_row)  -- Added for bug 3776650
            THEN
             old_party_account_id := NULL;
             old_party_id := NULL;
             IF l_temp_account_tbl.COUNT > 0
             THEN
                FOR l_old_acct IN l_temp_account_tbl.FIRST..l_temp_account_tbl.LAST
                LOOP
                 IF l_temp_account_tbl.EXISTS(l_old_acct)  -- Added for bug 3776650
                 THEN
                  IF l_temp_account_tbl(l_old_acct).ip_account_id = l_party_account_tbl(l_old_party_row).ip_account_id
                  THEN
                     old_party_account_id := l_temp_account_tbl(l_old_acct).ip_account_id;
                     old_party_id := l_temp_account_tbl(l_old_acct).attribute1;
                     EXIT;
                  END IF;
                 END IF;
                END LOOP;
             END IF;

               IF l_party_account_tbl(l_old_party_row).party_account_id IS NOT NULL AND
                  l_party_account_tbl(l_old_party_row).party_account_id <> FND_API.G_MISS_NUM AND
                  l_party_account_tbl(l_old_party_row).relationship_type_code = 'OWNER' AND
                  old_party_account_id IS NOT NULL AND
                  l_party_account_tbl(l_old_party_row).party_account_id <> old_party_account_id
               THEN
                  l_object_id := null;
                  Begin
                     select instance_id
                     into l_object_id
                     from CSI_I_PARTIES
                     where instance_party_id = l_party_account_tbl(l_old_party_row).instance_party_id
                     and   relationship_type_code = 'OWNER'
                     and   (active_end_date IS NULL OR active_end_date > sysdate);
                  Exception
                     when no_data_found then
                        l_object_id := null;
                  End;
                  --
                  IF l_object_id IS NOT NULL THEN
		     p_rel_query_rec.object_id := l_object_id;
		     p_rel_query_rec.relationship_type_code := 'COMPONENT-OF';
		     --
		     csi_ii_relationships_pvt.Get_Children
			( p_relationship_query_rec   => p_rel_query_rec,
			  p_rel_tbl                  => l_rel_tbl,
			  p_depth                    => NULL,
			  p_active_relationship_only => FND_API.G_TRUE,
			  p_time_stamp               => FND_API.G_MISS_DATE,
			  p_get_dfs                  => FND_API.G_FALSE,
                          p_ii_relationship_level_tbl => l_ii_relationship_level_tbl,
			  x_return_status            => x_return_status,
			  x_msg_count                => x_msg_count,
			  x_msg_data                 => x_msg_data
			);
		      --
		      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			 FND_MESSAGE.SET_NAME('CSI','CSI_API_GET_CHILDREN_ERROR');
			 FND_MSG_PUB.Add;
			 RAISE FND_API.G_EXC_ERROR;
		      END IF;
		      --
                      IF l_rel_tbl.count > 0 THEN
                         FOR j in l_rel_tbl.FIRST .. l_rel_tbl.LAST LOOP
                  -- FOR l_pty_acct_csr IN party_account_csr(l_party_account_tbl(l_old_party_row).instance_party_id)
                            l_party_account_tbl(l_old_party_row).ip_account_id := fnd_api.g_miss_num;
                            l_party_account_tbl(l_old_party_row).instance_party_id := fnd_api.g_miss_num;
                            l_party_account_tbl(l_old_party_row).object_version_number := fnd_api.g_miss_num;
                            l_party_account_tbl(l_old_party_row).active_start_date :=fnd_api.g_miss_date;
                            l_party_account_tbl(l_old_party_row).active_end_date :=fnd_api.g_miss_date;
                            BEGIN
                               l_party_id := NULL;
                               SELECT acct.ip_account_id,
                                      acct.object_version_number,
                                      pty.party_id
                               INTO   l_party_account_tbl(l_old_party_row).ip_account_id,
                                      l_party_account_tbl(l_old_party_row).object_version_number,
                                      l_party_id
                               FROM   csi_ip_accounts acct,
                                      csi_i_parties pty
                               WHERE  pty.instance_party_id = acct.instance_party_id
                               AND    pty.instance_id = l_rel_tbl(j).subject_id
                               AND    acct.relationship_type_code = 'OWNER'
                               AND    (acct.active_end_date IS NULL OR
                                      acct.active_end_date > SYSDATE);
                            EXCEPTION
                               WHEN OTHERS THEN
                                  NULL;
                            END;
                            --
			    IF l_party_account_tbl(l_old_party_row).ip_account_id IS NOT NULL AND
			       l_party_account_tbl(l_old_party_row).ip_account_id <> fnd_api.g_miss_num AND
			       old_party_id = l_party_id
			    THEN
			       csi_party_relationships_pvt.update_inst_party_account
				( p_api_version         => p_api_version
				 ,p_commit              => p_commit
				 ,p_init_msg_list       => p_init_msg_list
				 ,p_validation_level    => p_validation_level
				 ,p_party_account_rec   => l_party_account_tbl(l_old_party_row)
				 ,p_txn_rec             => p_txn_rec
                                 ,p_oks_txn_inst_tbl    => px_oks_txn_inst_tbl
				 ,x_return_status       => x_return_status
				 ,x_msg_count           => x_msg_count
				 ,x_msg_data            => x_msg_data);

				IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
				       l_msg_index := 1;
				       l_msg_count := x_msg_count;
				  WHILE l_msg_count > 0
				  LOOP
					   x_msg_data := FND_MSG_PUB.GET(
									 l_msg_index,
									 FND_API.G_FALSE   );
					  csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
					  l_msg_index := l_msg_index + 1;
					  l_msg_count := l_msg_count - 1;
				  END LOOP;
				     RAISE FND_API.G_EXC_ERROR;
				END IF;
			    END IF; -- ip_account_id not null check
                         END LOOP; -- l_rel_tbl loop
                      END IF; -- l_rel_tbl count check
                  END IF; -- l_object_id check
               END IF;
            END IF;
           END LOOP;
        END IF;

        -- End of fix for bug 2151750
        --
        -- End of API body

        -- Standard check of p_commit.
        IF FND_API.To_Boolean( p_commit ) THEN
           COMMIT WORK;
        END IF;

        /***** srramakr commented for bug # 3304439
        -- Check for the profile option and disable the trace
        IF (l_flag = 'Y') THEN
            dbms_session.set_sql_trace(false);
        END IF;
        -- End disable trace
        ****/

        -- Standard call to get message count and if count is  get message info.
        FND_MSG_PUB.Count_And_Get
                (p_count        =>      x_msg_count ,
                 p_data         =>      x_msg_data );
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO update_inst_party_acct_pub;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (  p_count   =>      x_msg_count,
                   p_data    =>      x_msg_data );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO update_inst_party_acct_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (   p_count   =>      x_msg_count,
                    p_data    =>      x_msg_data  );
        WHEN OTHERS THEN
                ROLLBACK TO update_inst_party_acct_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF FND_MSG_PUB.Check_Msg_Level
                     (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                   FND_MSG_PUB.Add_Exc_Msg
                    ( g_pkg_name, l_api_name );
                END IF;

                FND_MSG_PUB.Count_And_Get
                (  p_count   =>      x_msg_count,
                   p_data    =>      x_msg_data  );
END update_inst_party_account ;

/*--------------------------------------------------------*/
/* Procedure name: Expire_inst_party_account              */
/* Description :  Procedure used to expire an existing    */
/*                instance-party account relationships    */
/*--------------------------------------------------------*/

PROCEDURE expire_inst_party_account
 (    p_api_version                 IN     NUMBER
     ,p_commit                      IN     VARCHAR2
     ,p_init_msg_list               IN     VARCHAR2
     ,p_validation_level            IN     NUMBER
     ,p_party_account_tbl           IN     csi_datastructures_pub.party_account_tbl
     ,p_txn_rec                     IN OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status               OUT NOCOPY    VARCHAR2
     ,x_msg_count                   OUT NOCOPY    NUMBER
     ,x_msg_data                    OUT NOCOPY    VARCHAR2
   ) IS

      l_api_name      CONSTANT VARCHAR2(30)   :=  'EXPIRE_INST_PARTY_ACCOUNT';
      l_api_version   CONSTANT NUMBER             :=  1.0;
      l_csi_debug_level        NUMBER;
      l_msg_index              NUMBER ;
      l_msg_count              NUMBER;
      l_party_account_rec      csi_datastructures_pub.party_account_rec;
      l_line_count             NUMBER := 0 ;
      l_ip_account_id          NUMBER ;
      l_flag                   VARCHAR2(1)  :='N';

BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT  expire_inst_party_acct_pub;

     -- Check for freeze_flag in csi_install_parameters is set to 'Y'

     csi_utility_grp.check_ib_active;


        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (    l_api_version  ,
                                                p_api_version  ,
                                                l_api_name     ,
                                                g_pkg_name     )
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
             FND_MSG_PUB.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- Check the profile option CSI_DEBUG_LEVEL for debug message reporting
        l_csi_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

        -- If CSI_DEBUG_LEVEL = 1 then dump the procedure name
        IF (l_csi_debug_level > 0) THEN
            csi_gen_utility_pvt.put_line( 'expire_inst_party_account');
        END IF;


        -- If the debug level = 2 then dump all the parameters values.
        IF (l_csi_debug_level > 1) THEN
                csi_gen_utility_pvt.put_line( 'expire_inst_party_account:'||
                                                 p_api_version          ||'-'||
                                                 p_commit               ||'-'||
                                                 p_init_msg_list             );
               -- Dump the records in the log file
               csi_gen_utility_pvt.dump_party_account_tbl(p_party_account_tbl);
               csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);
        END IF;

        /***** srramakr commented for bug # 3304439
        -- Check for the profile option and enable trace
        l_flag:=csi_gen_utility_pvt.enable_trace(l_trace_flag => l_flag);
        -- End enable trace
        ****/

        -- Start API body
        --
        IF p_party_account_tbl.count > 0 THEN
          FOR l_count IN p_party_account_tbl.FIRST..p_party_account_tbl.LAST LOOP
            IF p_party_account_tbl.EXISTS(l_count) THEN
              csi_party_relationships_pvt.expire_inst_party_account
              ( p_api_version         => p_api_version
               ,p_commit              => p_commit
               ,p_init_msg_list       => p_init_msg_list
               ,p_validation_level    => p_validation_level
               ,p_party_account_rec   => p_party_account_tbl(l_count)
               ,p_txn_rec             => p_txn_rec
               ,x_return_status       => x_return_status
               ,x_msg_count           => x_msg_count
               ,x_msg_data            => x_msg_data  );


               IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                    l_msg_index := 1;
                    l_msg_count := x_msg_count;
                    WHILE l_msg_count > 0 LOOP
                     x_msg_data := FND_MSG_PUB.GET(
                                           l_msg_index,
                                                   FND_API.G_FALSE);
                     csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
                     l_msg_index := l_msg_index + 1;
                     l_msg_count := l_msg_count - 1;
                    END LOOP;
                  RAISE FND_API.G_EXC_ERROR;
                END IF;
            END IF;
          END LOOP;
        END IF;
        --
        -- End of API body

        -- Standard check of p_commit.
        IF FND_API.To_Boolean( p_commit ) THEN
                COMMIT WORK;
        END IF;

        /***** srramakr commented for bug # 3304439
        -- Check for the profile option and disable the trace
        IF (l_flag = 'Y') THEN
            dbms_session.set_sql_trace(false);
        END IF;
        -- End disable trace
        ****/

        -- Standard call to get message count and if count is  get message info.
        FND_MSG_PUB.Count_And_Get
                (p_count        =>      x_msg_count ,
                 p_data         =>      x_msg_data  );
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO expire_inst_party_acct_pub;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                ( p_count   =>      x_msg_count,
                  p_data    =>      x_msg_data  );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO expire_inst_party_acct_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (  p_count  =>      x_msg_count,
                   p_data   =>      x_msg_data );
        WHEN OTHERS THEN
                ROLLBACK TO expire_inst_party_acct_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level
                     (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                   FND_MSG_PUB.Add_Exc_Msg
                    ( g_pkg_name, l_api_name );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (  p_count   =>      x_msg_count,
                   p_data    =>      x_msg_data );
END expire_inst_party_account ;
END csi_party_relationships_pub ;


/
