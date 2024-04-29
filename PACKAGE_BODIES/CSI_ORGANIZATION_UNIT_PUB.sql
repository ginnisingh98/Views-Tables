--------------------------------------------------------
--  DDL for Package Body CSI_ORGANIZATION_UNIT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_ORGANIZATION_UNIT_PUB" AS
/* $Header: csipoub.pls 120.1 2005/08/16 10:51:46 sguthiva noship $ */

g_pkg_name   VARCHAR2(30) := 'csi_organization_unit_pub';

/*-------------------------------------------------------*/
/* procedure name: get_organization_unit                 */
/* description :   Get information about the org unit(s) */
/*                 associated with an item instance.     */
/*                 create item instances                 */
/*-------------------------------------------------------*/


PROCEDURE get_organization_unit
 (    p_api_version             IN      NUMBER
     ,p_commit                  IN      VARCHAR2
     ,p_init_msg_list           IN      VARCHAR2
     ,p_validation_level        IN      NUMBER
     ,p_ou_query_rec            IN      csi_datastructures_pub.organization_unit_query_rec
     ,p_resolve_id_columns      IN      VARCHAR2
     ,p_time_stamp              IN      DATE
     ,x_org_unit_tbl                OUT NOCOPY csi_datastructures_pub.org_units_header_tbl
     ,x_return_status               OUT NOCOPY VARCHAR2
     ,x_msg_count                   OUT NOCOPY NUMBER
     ,x_msg_data                    OUT NOCOPY VARCHAR2
 ) IS
    l_api_name      CONSTANT VARCHAR2(30)    := 'get_organization_unit';
    l_api_version   CONSTANT NUMBER          := 1.0;
    l_debug_level            NUMBER;
    l_ou_rec                 csi_datastructures_pub.org_units_header_rec;
    l_rows_processed         NUMBER;
    l_where_clause           VARCHAR2(2000)  := '';
    l_select_stmt            VARCHAR2(20000) := '  SELECT * FROM CSI_I_ORG_ASSIGNMENTS  ';
    l_cur_get_ou             NUMBER;
    l_count                  NUMBER          := 0;
    l_trace_enable_flag      VARCHAR2(1)     :='N';
    l_org_unit_tbl           csi_datastructures_pub.org_units_header_tbl;

BEGIN

    -- Standard Start of API savepoint
    --SAVEPOINT    get_organization_unit;

     -- Check for freeze_flag in csi_install_parameters is set to 'Y'

     csi_utility_grp.check_ib_active;


    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        g_pkg_name)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check the profile option debug_level for debug message reporting
    l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

    -- If debug_level = 1 then dump the procedure name
    IF (l_debug_level > 0) THEN
        csi_gen_utility_pvt.put_line( 'get_organization_unit');
    END IF;

    -- If the debug level = 2 then dump all the parameters values.
    IF (l_debug_level > 1) THEN
       csi_gen_utility_pvt.put_line( p_api_version   ||'-'
                    || p_commit                         ||'-'
                    || p_init_msg_list                  ||'-'
                    || p_time_stamp  );

       -- Dump ou_query_rec
       csi_gen_utility_pvt.dump_ou_query_rec(p_ou_query_rec);
    END IF;

    /***** srramakr commented for bug # 3304439
    -- Check for the profile option and enable trace
    l_trace_enable_flag:=CSI_GEN_UTILITY_PVT.enable_trace(l_trace_flag => l_trace_enable_flag);
    -- End enable trace
    ****/


    -- Start API body
    -- Check if at least one query parameters are passed
    IF ( p_ou_query_rec.instance_ou_id  = FND_API.G_MISS_NUM)
       AND ( p_ou_query_rec.instance_id = FND_API.G_MISS_NUM)
       AND ( p_ou_query_rec.operating_unit_id = FND_API.G_MISS_NUM)
       AND ( p_ou_query_rec.relationship_type_code = FND_API.G_MISS_CHAR) THEN

       FND_MESSAGE.Set_Name('CSI', 'CSI_API_INVALID_PARAMETERS');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;


    -- Generate the where clause
    csi_organization_unit_pvt.Gen_ou_Where_Clause
        (p_ou_query_rec     =>   p_ou_query_rec,
         x_where_clause     =>  l_where_clause    );

    -- Build the select statement
    l_select_stmt := l_select_stmt || ' where '||l_where_clause;


    -- Open the cursor
    l_cur_get_ou := dbms_sql.open_cursor;


    --Parse the select statement
    dbms_sql.parse(l_cur_get_ou, l_select_stmt , dbms_sql.native);


    -- Bind the variables
     csi_organization_unit_pvt.Bind_ou_variable
         ( p_ou_query_rec,
           l_cur_get_ou );


    -- Define output variables
    csi_organization_unit_pvt.Define_ou_Columns(l_cur_get_ou);

     -- execute the select statement
    l_rows_processed := dbms_sql.execute(l_cur_get_ou);


    LOOP
    EXIT WHEN DBMS_SQL.FETCH_ROWS(l_cur_get_ou) = 0;
          csi_organization_unit_pvt.Get_ou_Column_Values(l_cur_get_ou, l_ou_rec);
          l_count := l_count + 1;
          x_org_unit_tbl(l_count) := l_ou_rec;
    END LOOP;

    -- Close the cursor
    DBMS_SQL.CLOSE_CURSOR(l_cur_get_ou);

    IF (p_time_stamp IS NOT NULL) AND (p_time_stamp <> FND_API.G_MISS_DATE) THEN
      IF p_time_stamp <= sysdate THEN
            csi_organization_unit_pvt.Construct_ou_From_Hist(x_org_unit_tbl, p_time_stamp);
      ELSE
            FND_MESSAGE.Set_Name('CSI', 'CSI_API_INVALID_HIST_PARAMS');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

   -- Resolve the foreign key columns if p_resolve_id_columns is true
    IF p_resolve_id_columns = fnd_api.g_true THEN
       IF x_org_unit_tbl.count > 0 THEN
           l_org_unit_tbl := x_org_unit_tbl;
           csi_organization_unit_pvt.Resolve_id_columns(l_org_unit_tbl);

           x_org_unit_tbl := l_org_unit_tbl;
       END IF;
    END IF;

    -- End of API body

    -- Standard check of p_commit.
    /*
    IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT WORK;
    END IF;
    */

    /***** srramakr commented for bug # 3304439
    -- Check for the profile option and disable the trace
    IF (l_trace_enable_flag = 'Y') THEN
       dbms_session.set_sql_trace(false);
    END IF;
    -- End disable trace
    ****/

    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get
        (p_count     =>     x_msg_count ,
          p_data     =>     x_msg_data
        );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
       -- ROLLBACK TO get_organization_unit;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (   p_count   =>      x_msg_count,
                p_data    =>      x_msg_data
             );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       -- ROLLBACK TO get_organization_unit;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (   p_count   =>      x_msg_count,
                p_data    =>      x_msg_data
             );

    WHEN OTHERS THEN
        IF DBMS_SQL.IS_OPEN(l_cur_get_ou) THEN
              DBMS_SQL.CLOSE_CURSOR(l_cur_get_ou);
        END IF;
       -- ROLLBACK TO  get_organization_unit;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF     FND_MSG_PUB.Check_Msg_Level
                 (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg
                (    g_pkg_name,
                    l_api_name
                 );
        END IF;

        FND_MSG_PUB.Count_And_Get
            (   p_count   =>      x_msg_count,
                p_data    =>      x_msg_data
            );

END get_organization_unit;


/*-------------------------------------------------------*/
/* procedure name: create_organization_unit              */
/* description :  Creates new association between an     */
/*                organization unit and an item instance */
/*                                                       */
/*-------------------------------------------------------*/

PROCEDURE create_organization_unit
 (    p_api_version         IN      NUMBER
     ,p_commit              IN      VARCHAR2
     ,p_init_msg_list       IN      VARCHAR2
     ,p_validation_level    IN      NUMBER
     ,p_org_unit_tbl        IN  OUT NOCOPY csi_datastructures_pub.organization_units_tbl
     ,p_txn_rec             IN  OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status           OUT NOCOPY VARCHAR2
     ,x_msg_count               OUT NOCOPY NUMBER
     ,x_msg_data                OUT NOCOPY VARCHAR2
 )
 IS

    l_api_name           CONSTANT VARCHAR2(30)   := 'create_organization_unit';
    l_api_version        CONSTANT NUMBER         := 1.0;
    l_debug_level                 NUMBER;
    l_org_unit_tbl                csi_datastructures_pub.organization_units_tbl;
    l_txn_rec                     csi_datastructures_pub.transaction_rec;
    l_msg_index                   NUMBER;
    l_msg_count                   NUMBER;
    l_trace_enable_flag           VARCHAR2(1)  :='N';
    l_ou_lookup_tbl               csi_organization_unit_pvt.lookup_tbl;
    l_ou_count_rec                csi_organization_unit_pvt.ou_count_rec;
    l_ou_id_tbl                   csi_organization_unit_pvt.ou_id_tbl;

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT    create_organization_unit;

     -- Check for freeze_flag in csi_install_parameters is set to 'Y'

     csi_utility_grp.check_ib_active;


    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name ,
                                        g_pkg_name)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;


    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Check the profile option debug_level for debug message reporting
    l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

    -- If debug_level = 1 then dump the procedure name
    IF (l_debug_level > 0) THEN
        csi_gen_utility_pvt.put_line( 'create_organization_unit');
    END IF;


    -- If the debug level = 2 then dump all the parameters values.
    IF (l_debug_level > 1) THEN
      csi_gen_utility_pvt.put_line( p_api_version     ||'-'
                    || p_commit                          ||'-'
                    || p_init_msg_list                   ||'-'
                    || p_validation_level );

      -- Dump org_unit_tbl
      csi_gen_utility_pvt.dump_organization_unit_tbl(p_org_unit_tbl);
      --Dump txn_rec
      csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);

    END IF;

    /***** srramakr commented for bug # 3304439
    -- Check for the profile option and enable trace
    l_trace_enable_flag:=CSI_GEN_UTILITY_PVT.enable_trace(l_trace_flag => l_trace_enable_flag);
    -- End enable trace
    ****/

    -- Start API body
     IF p_org_unit_tbl.COUNT > 0 THEN
         FOR tab_row IN p_org_unit_tbl.FIRST .. p_org_unit_tbl.LAST
         LOOP
           IF p_org_unit_tbl.EXISTS(tab_row) THEN
            csi_organization_unit_pvt.create_organization_unit
            ( p_api_version       => p_api_version
             ,p_commit            => fnd_api.g_false
             ,p_init_msg_list     => p_init_msg_list
             ,p_validation_level  => p_validation_level
             ,p_org_unit_rec      => p_org_unit_tbl(tab_row)
             ,p_txn_rec           => p_txn_rec
             ,x_return_status     => x_return_status
             ,x_msg_count         => x_msg_count
             ,x_msg_data          => x_msg_data
             ,p_lookup_tbl        => l_ou_lookup_tbl
             ,p_ou_count_rec      => l_ou_count_rec
             ,p_ou_id_tbl         => l_ou_id_tbl
            );

             IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                 l_msg_index := 1;
                 l_msg_count := x_msg_count;
                 WHILE l_msg_count > 0 LOOP
                    x_msg_data := FND_MSG_PUB.GET
                          (  l_msg_index,
                             FND_API.G_FALSE     );

                    csi_gen_utility_pvt.put_line( ' Failed Pub:create_organization_unit..');
                    csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
                    l_msg_index := l_msg_index + 1;
                    l_msg_count := l_msg_count - 1;
                 END LOOP;
                 RAISE FND_API.G_EXC_ERROR;
            END IF;


            END IF;
         END LOOP;
    END IF;

    -- End of API body


    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

   /***** srramakr commented for bug # 3304439
   -- Check for the profile option and disable the trace
   IF (l_trace_enable_flag = 'Y') THEN
      dbms_session.set_sql_trace(false);
   END IF;
   -- End disable trace
   ****/

    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get
        (p_count     =>     x_msg_count ,
         p_data      =>     x_msg_data
        );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_organization_unit;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (   p_count   =>      x_msg_count,
                p_data    =>      x_msg_data
            );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_organization_unit;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (   p_count   =>      x_msg_count,
                p_data    =>      x_msg_data
             );

    WHEN OTHERS THEN
        ROLLBACK TO  create_organization_unit;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF     FND_MSG_PUB.Check_Msg_Level
                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg
                (   g_pkg_name,
                    l_api_name
                );
        END IF;

        FND_MSG_PUB.Count_And_Get
            (   p_count   =>      x_msg_count,
                p_data    =>      x_msg_data
            );

END create_organization_unit;



/*-------------------------------------------------------*/
/* procedure name: update_organization_unit              */
/* description :  Updates an existing instance-org       */
/*                association                            */
/*                                                       */
/*-------------------------------------------------------*/

PROCEDURE update_organization_unit
 (
      p_api_version            IN     NUMBER
     ,p_commit                 IN     VARCHAR2
     ,p_init_msg_list          IN     VARCHAR2
     ,p_validation_level       IN     NUMBER
     ,p_org_unit_tbl           IN     csi_datastructures_pub.organization_units_tbl
     ,p_txn_rec                IN OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status             OUT NOCOPY VARCHAR2
     ,x_msg_count                 OUT NOCOPY NUMBER
     ,x_msg_data                  OUT NOCOPY VARCHAR2
 )

IS
    l_api_name       CONSTANT VARCHAR2(30)   := 'UPDATE_ORGANIZATION_UNIT';
    l_api_version    CONSTANT NUMBER         := 1.0;
    l_debug_level             NUMBER;
    l_msg_count               NUMBER;
    l_msg_index               NUMBER;
    l_trace_enable_flag       VARCHAR2(1)    :='N';
    l_ou_lookup_tbl           csi_organization_unit_pvt.lookup_tbl;
    l_ou_count_rec            csi_organization_unit_pvt.ou_count_rec;
    l_ou_id_tbl               csi_organization_unit_pvt.ou_id_tbl;

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT    update_organization_unit;

     -- Check for freeze_flag in csi_install_parameters is set to 'Y'

     csi_utility_grp.check_ib_active;


    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name ,
                                        g_pkg_name)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;


    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Check the profile option debug_level for debug message reporting
    l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

    -- If debug_level = 1 then dump the procedure name
    IF (l_debug_level > 0) THEN
        csi_gen_utility_pvt.put_line( 'update_organization_unit');
    END IF;


    -- If the debug level = 2 then dump all the parameters values.
    IF (l_debug_level > 1) THEN
        csi_gen_utility_pvt.put_line( p_api_version      ||'-'
                     || p_commit                            ||'-'
                     || p_init_msg_list                     ||'-'
                     || p_validation_level );
     -- Dump org_unit_tbl
      csi_gen_utility_pvt.dump_organization_unit_tbl(p_org_unit_tbl);
     -- Dump txn_rec
      csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);

    END IF;

    /***** srramakr commented for bug # 3304439
    -- Check for the profile option and enable trace
        l_trace_enable_flag:=CSI_GEN_UTILITY_PVT.enable_trace(l_trace_flag => l_trace_enable_flag);
    -- End enable trace
    ****/
    -- Start API body
     IF p_org_unit_tbl.COUNT > 0 THEN
        FOR tab_row IN p_org_unit_tbl.FIRST .. p_org_unit_tbl.LAST
        LOOP
           IF p_org_unit_tbl.EXISTS(tab_row) THEN
            csi_organization_unit_pvt.update_organization_unit
            ( p_api_version         => p_api_version
             ,p_commit              => fnd_api.g_false
             ,p_init_msg_list       => p_init_msg_list
             ,p_validation_level    => p_validation_level
             ,p_org_unit_rec        => p_org_unit_tbl(tab_row)
             ,p_txn_rec             => p_txn_rec
             ,x_return_status       => x_return_status
             ,x_msg_count           => x_msg_count
             ,x_msg_data            => x_msg_data
             ,p_lookup_tbl          => l_ou_lookup_tbl
             ,p_ou_count_rec        => l_ou_count_rec
             ,p_ou_id_tbl           => l_ou_id_tbl
            );

             IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                l_msg_index := 1;
                 l_msg_count := x_msg_count;
                WHILE l_msg_count > 0 LOOP
                    x_msg_data := FND_MSG_PUB.GET
                          (  l_msg_index,
                          FND_API.G_FALSE     );

                    csi_gen_utility_pvt.put_line( ' Failed Pub:update_organization_unit..');
                    csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
                    l_msg_index := l_msg_index + 1;
                    l_msg_count := l_msg_count - 1;
                END LOOP;
                RAISE FND_API.G_EXC_ERROR;
              END IF;

            END IF;
         END LOOP;
    END IF;

    -- End of API body

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

   /***** srramakr commented for bug # 3304439
   -- Check for the profile option and disable the trace
   IF (l_trace_enable_flag = 'Y') THEN
      dbms_session.set_sql_trace(false);
   END IF;
   -- End disable trace
   ****/

    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get
        (p_count     =>     x_msg_count ,
          p_data     =>     x_msg_data
         );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO update_organization_unit;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get
        (   p_count       =>      x_msg_count,
            p_data        =>      x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_organization_unit;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
             (  p_count   =>      x_msg_count,
                p_data    =>      x_msg_data
              );

    WHEN OTHERS THEN
        ROLLBACK TO  update_organization_unit;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF     FND_MSG_PUB.Check_Msg_Level
               (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
             FND_MSG_PUB.Add_Exc_Msg
                (   g_pkg_name,
                    l_api_name
                );
        END IF;

        FND_MSG_PUB.Count_And_Get
            (   p_count   =>      x_msg_count,
                p_data    =>      x_msg_data
            );

END update_organization_unit;

/*------------------------------------------------------ */
/* procedure name: expire_organization_unit              */
/* description :  Expires an existing instance-org       */
/*                association                            */
/*                                                       */
/*-------------------------------------------------------*/

PROCEDURE expire_organization_unit
 (
      p_api_version                 IN       NUMBER
     ,p_commit                      IN       VARCHAR2
     ,p_init_msg_list               IN       VARCHAR2
     ,p_validation_level            IN       NUMBER
     ,p_org_unit_tbl                IN       csi_datastructures_pub.organization_units_tbl
     ,p_txn_rec                     IN  OUT NOCOPY  csi_datastructures_pub.transaction_rec
     ,x_return_status                   OUT NOCOPY  VARCHAR2
     ,x_msg_count                       OUT NOCOPY  NUMBER
     ,x_msg_data                        OUT NOCOPY  VARCHAR2
 )

IS
    l_api_name       CONSTANT VARCHAR2(30)   := 'expire_organization_unit';
    l_api_version    CONSTANT NUMBER         := 1.0;
    l_debug_level             NUMBER;
    l_msg_index               NUMBER;
    l_msg_count               NUMBER;
    l_trace_enable_flag       VARCHAR2(1)    :='N';
BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT    expire_organization_unit;

     -- Check for freeze_flag in csi_install_parameters is set to 'Y'

     csi_utility_grp.check_ib_active;


    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name ,
                                        g_pkg_name)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;


    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Check the profile option debug_level for debug message reporting
    l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

    -- If debug_level = 1 then dump the procedure name
    IF (l_debug_level > 0) THEN
        csi_gen_utility_pvt.put_line( 'expire_organization_unit');
    END IF;

    -- If the debug level = 2 then dump all the parameters values.
    IF (l_debug_level > 1) THEN
       csi_gen_utility_pvt.put_line( p_api_version     ||'-'
                          || p_commit                     ||'-'
                          || p_init_msg_list              ||'-'
                          || p_validation_level );
       -- Dump org_unit_tbl
       csi_gen_utility_pvt.dump_organization_unit_tbl(p_org_unit_tbl);
       -- Dump txn_rec
       csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);
    END IF;

    /***** srramakr commented for bug # 3304439
    -- Check for the profile option and enable trace
    l_trace_enable_flag:=CSI_GEN_UTILITY_PVT.enable_trace(l_trace_flag => l_trace_enable_flag);
    -- End enable trace
    ****/

    -- Start API body
    IF p_org_unit_tbl.COUNT > 0 THEN
        FOR tab_row IN p_org_unit_tbl.FIRST .. p_org_unit_tbl.LAST
        LOOP
           IF p_org_unit_tbl.EXISTS(tab_row) THEN
              csi_organization_unit_pvt.expire_organization_unit
              ( p_api_version       => p_api_version
                ,p_commit           => fnd_api.g_false
                ,p_init_msg_list    => p_init_msg_list
                ,p_validation_level => p_validation_level
                ,p_org_unit_rec     => p_org_unit_tbl(tab_row)
                ,p_txn_rec          => p_txn_rec
                ,x_return_status    => x_return_status
                ,x_msg_count        => x_msg_count
                ,x_msg_data         => x_msg_data
               );

               IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  l_msg_index := 1;
                 l_msg_count := x_msg_count;
                  WHILE l_msg_count > 0 LOOP
                       x_msg_data := FND_MSG_PUB.GET
                          (  l_msg_index,
                          FND_API.G_FALSE     );

                        csi_gen_utility_pvt.put_line( ' Failed Pub:expire_organization_unit..');
                        csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
                        l_msg_index := l_msg_index + 1;
                        l_msg_count := l_msg_count - 1;
                  END LOOP;
                  RAISE FND_API.G_EXC_ERROR;
                END IF;
            END IF;
         END LOOP;
     END IF;

    -- End of API body




    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

   /***** srramakr commented for bug # 3304439
   -- Check for the profile option and disable the trace
   IF (l_trace_enable_flag = 'Y') THEN
      dbms_session.set_sql_trace(false);
   END IF;
   -- End disable trace
   ****/

   -- Standard call to get message count and if count is  get message info.
   FND_MSG_PUB.Count_And_Get
        (p_count     =>     x_msg_count ,
          p_data     =>     x_msg_data
        );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO expire_organization_unit;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (   p_count   =>      x_msg_count,
                p_data    =>      x_msg_data
             );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO expire_organization_unit;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (   p_count   =>      x_msg_count,
                p_data    =>      x_msg_data
            );

    WHEN OTHERS THEN
        ROLLBACK TO  expire_organization_unit;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF  FND_MSG_PUB.Check_Msg_Level
            (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg
                (    g_pkg_name,
                     l_api_name
                );
        END IF;

        FND_MSG_PUB.Count_And_Get
            (   p_count   =>      x_msg_count,
                p_data    =>      x_msg_data
            );

END expire_organization_unit;



END csi_organization_unit_pub;


/
