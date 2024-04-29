--------------------------------------------------------
--  DDL for Package Body CSI_PRICING_ATTRIBS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_PRICING_ATTRIBS_PUB" AS
/* $Header: csippab.pls 120.1 2005/08/16 10:48:54 sguthiva noship $ */

g_pkg_name   VARCHAR2(30) := 'csi_pricing_attribs_pub';

/*------------------------------------------------------*/
/* procedure name: get_pricing_attribs                  */
/* description :   Gets the pricing attributes of an    */
/*                 item instance                        */
/*------------------------------------------------------*/


PROCEDURE get_pricing_attribs
 (    p_api_version               IN     NUMBER
     ,p_commit                    IN     VARCHAR2
     ,p_init_msg_list             IN     VARCHAR2
     ,p_validation_level          IN     NUMBER
     ,p_pricing_attribs_query_rec IN     csi_datastructures_pub.pricing_attribs_query_rec
     ,p_time_stamp                IN     DATE
     ,x_pricing_attribs_tbl          OUT NOCOPY csi_datastructures_pub.pricing_attribs_tbl
     ,x_return_status                OUT NOCOPY VARCHAR2
     ,x_msg_count                    OUT NOCOPY NUMBER
     ,x_msg_data                     OUT NOCOPY VARCHAR2
 )

IS
    l_api_name       CONSTANT VARCHAR2(30)   := 'get_pricing_attribs';
    l_api_version    CONSTANT NUMBER         := 1.0;
    l_debug_level             NUMBER;
    l_pri_rec                 csi_datastructures_pub.pricing_attribs_rec;
    l_rows_processed          NUMBER;
    l_where_clause            VARCHAR2(2000) := '';
    l_select_stmt             VARCHAR2(20000) := 'SELECT * FROM csi_i_pricing_attribs  ';
    l_cur_get_pri             NUMBER;
    l_count                   NUMBER := 0;
    l_trace_enable_flag       VARCHAR2(1)  :='N';

BEGIN

    -- Standard Start of API savepoint
   -- SAVEPOINT    get_pricing_attribs;

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
        csi_gen_utility_pvt.put_line( 'get_pricing_attribs');
    END IF;


    -- If the debug level = 2 then dump all the parameters values.
    IF (l_debug_level > 1) THEN
      csi_gen_utility_pvt.put_line( p_api_version       ||'-'
                        || p_commit                        ||'-'
                        || p_init_msg_list                 ||'-'
                        || p_validation_level              ||'-'
                        || p_time_stamp );

       -- Dump pricing_attribs_rec
       csi_gen_utility_pvt.dump_pricing_attribs_query_rec(p_pricing_attribs_query_rec);
     END IF;

     /***** srramakr commented for bug # 3304439
     -- Check for the profile option and enable trace
         l_trace_enable_flag:=CSI_GEN_UTILITY_PVT.enable_trace(l_trace_flag => l_trace_enable_flag);
     -- End enable trace
     *****/

    -- Start API body
    -- check if atleast one query parameters are passed
      IF (p_pricing_attribs_query_rec.pricing_attribute_id = FND_API.G_MISS_NUM)
           AND (p_pricing_attribs_query_rec.instance_id = FND_API.G_MISS_NUM) THEN
           FND_MESSAGE.Set_Name('CSI', 'CSI_API_INVALID_PARAMETERS');
           FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
      END IF;


       -- Generate the where clause
       csi_pricing_attribs_pvt.Gen_pri_Where_Clause
          ( p_pri_query_rec      =>   p_pricing_attribs_query_rec,
            x_where_clause       =>  l_where_clause    );

       -- Build the select statement
       l_select_stmt := l_select_stmt || ' where '||l_where_clause;

       -- Open the cursor
       l_cur_get_pri := dbms_sql.open_cursor;

       --Parse the select statement
       dbms_sql.parse(l_cur_get_pri, l_select_stmt , dbms_sql.native);

       -- Bind the variables
        csi_pricing_attribs_pvt.Bind_pri_variable
            (p_pricing_attribs_query_rec,
            l_cur_get_pri            );

       -- Define output variables
       csi_pricing_attribs_pvt.Define_pri_Columns(l_cur_get_pri);

       -- execute the select statement
       l_rows_processed := dbms_sql.execute(l_cur_get_pri);


       LOOP
       EXIT WHEN DBMS_SQL.FETCH_ROWS(l_cur_get_pri) = 0;
          csi_pricing_attribs_pvt.Get_pri_Column_Values(l_cur_get_pri, l_pri_rec);
          l_count := l_count + 1;
          x_pricing_attribs_tbl(l_count) := l_pri_rec;
       END LOOP;

       -- Close the cursor
       DBMS_SQL.CLOSE_CURSOR(l_cur_get_pri);

       IF (p_time_stamp IS NOT NULL) AND (p_time_stamp <> FND_API.G_MISS_DATE) THEN
         IF p_time_stamp <= sysdate THEN
            csi_pricing_attribs_pvt.Construct_pri_From_Hist(x_pricing_attribs_tbl, p_time_stamp);
         ELSE
            FND_MESSAGE.Set_Name('CSI', 'CSI_API_INVALID_PARAMETERS');
            FND_MESSAGE.SET_TOKEN('TIME_STAMP',p_time_stamp);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
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
      --  ROLLBACK TO get_pricing_attribs;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (   p_count    =>      x_msg_count,
                p_data     =>      x_msg_data
             );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --  ROLLBACK TO get_pricing_attribs;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (   p_count    =>      x_msg_count,
                p_data     =>      x_msg_data
            );

    WHEN OTHERS THEN
        IF DBMS_SQL.IS_OPEN(l_cur_get_pri) THEN
              DBMS_SQL.CLOSE_CURSOR(l_cur_get_pri);
        END IF;

      --  ROLLBACK TO  get_pricing_attribs;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF     FND_MSG_PUB.Check_Msg_Level
               (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg
                (    g_pkg_name ,
                     l_api_name
                 );
        END IF;

        FND_MSG_PUB.Count_And_Get
            (   p_count    =>      x_msg_count,
                p_data     =>      x_msg_data
             );

END get_pricing_attribs;


/*------------------------------------------------------*/
/* procedure name: create_pricing_attribs               */
/* description :  Associates pricing attributes to an   */
/*                item instance                         */
/*------------------------------------------------------*/


PROCEDURE create_pricing_attribs
 (    p_api_version         IN     NUMBER
     ,p_commit              IN     VARCHAR2
     ,p_init_msg_list       IN     VARCHAR2
     ,p_validation_level    IN     NUMBER
     ,p_pricing_attribs_tbl IN OUT NOCOPY csi_datastructures_pub.pricing_attribs_tbl
     ,p_txn_rec             IN OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status          OUT NOCOPY VARCHAR2
     ,x_msg_count              OUT NOCOPY NUMBER
     ,x_msg_data               OUT NOCOPY VARCHAR2
 )

IS
    l_api_name          CONSTANT VARCHAR2(30)   := 'CREATE_PRICING_ATTRIBS';
    l_api_version       CONSTANT NUMBER        := 1.0;
    l_debug_level                NUMBER;
    l_msg_index                  NUMBER;
    l_msg_count                  NUMBER;
    l_trace_enable_flag          VARCHAR2(1)  :='N';

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT    create_pricing_attribs;

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
        csi_gen_utility_pvt.put_line( 'create_pricing_attribs');
    END IF;


    -- If the debug level = 2 then dump all the parameters values.
    IF (l_debug_level > 1) THEN
       csi_gen_utility_pvt.put_line( p_api_version ||'-'
                     || p_commit                      ||'-'
                     || p_init_msg_list               ||'-'
                     || p_validation_level     );
       -- Dump pricing_attribs_tbl
       csi_gen_utility_pvt.dump_pricing_attribs_tbl(p_pricing_attribs_tbl);
       -- Dump txn_rec
       csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);

    END IF;

    /***** srramakr commented for bug # 3304439
    -- Check for the profile option and enable trace
        l_trace_enable_flag:=CSI_GEN_UTILITY_PVT.enable_trace(l_trace_flag => l_trace_enable_flag);
    -- End enable trace
    ****/

    -- Start API body

     IF p_pricing_attribs_tbl.COUNT > 0 THEN
         FOR tab_row IN p_pricing_attribs_tbl.FIRST .. p_pricing_attribs_tbl.LAST
         LOOP
            IF p_pricing_attribs_tbl.EXISTS(tab_row) THEN
               csi_pricing_attribs_pvt.create_pricing_attribs
                ( p_api_version         => p_api_version
                 ,p_commit              => p_commit
                 ,p_init_msg_list       => p_init_msg_list
                 ,p_validation_level    => p_validation_level
                 ,p_pricing_attribs_rec => p_pricing_attribs_tbl(tab_row)
                 ,p_txn_rec             => p_txn_rec
                 ,x_return_status       => x_return_status
                 ,x_msg_count           =>  x_msg_count
                 ,x_msg_data            =>  x_msg_data
                 );

                IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                   l_msg_index := 1;
                   l_msg_count := x_msg_count;
                   WHILE l_msg_count > 0 LOOP
                      x_msg_data := FND_MSG_PUB.GET
                          (  l_msg_index,
                             FND_API.G_FALSE );

                      csi_gen_utility_pvt.put_line( ' Failed Pub:create_pricing_attribs..');
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
        ROLLBACK TO create_pricing_attribs;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (   p_count    =>      x_msg_count,
                p_data     =>      x_msg_data
             );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_pricing_attribs;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (   p_count    =>      x_msg_count,
                p_data     =>      x_msg_data
             );

    WHEN OTHERS THEN
        ROLLBACK TO  create_pricing_attribs;
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
             (  p_count    =>      x_msg_count,
                p_data     =>      x_msg_data
             );

END create_pricing_attribs;



/*------------------------------------------------------*/
/* procedure name: update_pricing_attribs               */
/* description :  Updates the existing pricing          */
/*                attributes for an item instance       */
/*                                                      */
/*------------------------------------------------------*/


PROCEDURE update_pricing_attribs
 (    p_api_version             IN     NUMBER
     ,p_commit                  IN     VARCHAR2
     ,p_init_msg_list           IN     VARCHAR2
     ,p_validation_level        IN     NUMBER
     ,p_pricing_attribs_tbl     IN     csi_datastructures_pub.pricing_attribs_tbl
     ,p_txn_rec                 IN OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status              OUT NOCOPY VARCHAR2
     ,x_msg_count                  OUT NOCOPY NUMBER
     ,x_msg_data                   OUT NOCOPY VARCHAR2
 )

IS
    l_api_name       CONSTANT VARCHAR2(30)   := 'UPDATE_PRICING_ATTRIBS';
    l_api_version    CONSTANT NUMBER         := 1.0;
    l_debug_level                NUMBER;
    l_msg_index               NUMBER;
    l_msg_count               NUMBER;
    l_trace_enable_flag       VARCHAR2(1)    :='N';

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT    update_pricing_attribs;

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
        csi_gen_utility_pvt.put_line( 'update_pricing_attribs');
    END IF;


    -- If the debug level = 2 then dump all the parameters values.
    IF (l_debug_level > 1) THEN
       csi_gen_utility_pvt.put_line( p_api_version ||'-'
                       || p_commit                    ||'-'
                       || p_init_msg_list             ||'-'
                       || p_validation_level);
     -- Dump pricing_attribs_tbl
        csi_gen_utility_pvt.dump_pricing_attribs_tbl(p_pricing_attribs_tbl);
     -- Dump txn_rec
        csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);
    END IF;

    /***** srramakr commented for bug # 3304439
    -- Check for the profile option and enable trace
    l_trace_enable_flag:=CSI_GEN_UTILITY_PVT.enable_trace(l_trace_flag => l_trace_enable_flag);
    -- End enable trace
    ****/

    -- Start API body
    IF p_pricing_attribs_tbl.COUNT > 0 THEN
        FOR tab_row IN p_pricing_attribs_tbl.FIRST .. p_pricing_attribs_tbl.LAST
        LOOP
          IF p_pricing_attribs_tbl.EXISTS(tab_row) THEN
              csi_pricing_attribs_pvt.update_pricing_attribs
              ( p_api_version          => p_api_version
               ,p_commit               => fnd_api.g_false
               ,p_init_msg_list        => p_init_msg_list
               ,p_validation_level     => p_validation_level
               ,p_pricing_attribs_rec  => p_pricing_attribs_tbl(tab_row)
               ,p_txn_rec              => p_txn_rec
               ,x_return_status        => x_return_status
               ,x_msg_count            => x_msg_count
               ,x_msg_data             => x_msg_data
               );

              IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  l_msg_index := 1;

                   l_msg_count := x_msg_count;
                  WHILE l_msg_count > 0 LOOP
                     x_msg_data := FND_MSG_PUB.GET
                                      (l_msg_index,
                                       FND_API.G_FALSE  );

                     csi_gen_utility_pvt.put_line( ' Failed Pub:update_pricing_attribs..');
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
        ROLLBACK TO update_pricing_attribs;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (  p_count     =>      x_msg_count,
                p_data     =>      x_msg_data
             );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_pricing_attribs;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (   p_count    =>      x_msg_count,
                p_data     =>      x_msg_data
             );

    WHEN OTHERS THEN
        ROLLBACK TO  update_pricing_attribs;
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
            (   p_count    =>      x_msg_count,
                p_data     =>      x_msg_data
             );

END update_pricing_attribs;



/*--------------------------------------------------------*/
/* procedure name: expire_pricing_attribs                 */
/* description :  Expires the existing pricing            */
/*                attributes for an item instance         */
/*                                                        */
/*--------------------------------------------------------*/


PROCEDURE expire_pricing_attribs
 (    p_api_version                 IN     NUMBER
     ,p_commit                      IN     VARCHAR2
     ,p_init_msg_list               IN     VARCHAR2
     ,p_validation_level            IN     NUMBER
     ,p_pricing_attribs_tbl         IN     csi_datastructures_pub.pricing_attribs_tbl
     ,p_txn_rec                     IN OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status                  OUT NOCOPY VARCHAR2
     ,x_msg_count                      OUT NOCOPY NUMBER
     ,x_msg_data                       OUT NOCOPY VARCHAR2
 )

IS
    l_api_name       CONSTANT VARCHAR2(30)   := 'EXPIRE_PRICING_ATTRIBS';
    l_api_version    CONSTANT NUMBER         := 1.0;
    l_debug_level             NUMBER;
    l_msg_index               NUMBER;
    l_msg_count               NUMBER;
    l_trace_enable_flag       VARCHAR2(1)  :='N';

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT    expire_pricing_attribs;

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
        csi_gen_utility_pvt.put_line( 'expire_pricing_attribs');
    END IF;


    -- If the debug level = 2 then dump all the parameters values.
    IF (l_debug_level > 1) THEN
       csi_gen_utility_pvt.put_line( p_api_version ||'-'
                     || p_commit                      ||'-'
                     || p_init_msg_list               ||'-'
                     || p_validation_level  );

       -- Dump pricing_attribs_tbl
        csi_gen_utility_pvt.dump_pricing_attribs_tbl(p_pricing_attribs_tbl);
       -- Dump txn_rec
        csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);

    END IF;

    /***** srramakr commented for bug # 3304439
    -- Check for the profile option and enable trace
    l_trace_enable_flag:=CSI_GEN_UTILITY_PVT.enable_trace(l_trace_flag => l_trace_enable_flag);
    -- End enable trace
    ****/

    -- Start API body
    IF p_pricing_attribs_tbl.COUNT > 0 THEN
        FOR tab_row IN p_pricing_attribs_tbl.FIRST .. p_pricing_attribs_tbl.LAST
        LOOP
            IF p_pricing_attribs_tbl.EXISTS(tab_row) THEN
              csi_pricing_attribs_pvt.expire_pricing_attribs
              ( p_api_version             => p_api_version
               ,p_commit                  => fnd_api.g_false
               ,p_init_msg_list           => p_init_msg_list
               ,p_validation_level        => p_validation_level
               ,p_pricing_attribs_rec     => p_pricing_attribs_tbl(tab_row)
               ,p_txn_rec                 => p_txn_rec
               ,x_return_status           => x_return_status
               ,x_msg_count               => x_msg_count
               ,x_msg_data                => x_msg_data
               );

               IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                   l_msg_index := 1;
                   l_msg_count := x_msg_count;
                   WHILE l_msg_count > 0 LOOP
                     x_msg_data := FND_MSG_PUB.GET
                          (l_msg_index,
                           FND_API.G_FALSE );

                     csi_gen_utility_pvt.put_line( ' Failed Pub:expire_pricing_attribs..');
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

        ROLLBACK TO expire_pricing_attribs;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (   p_count    =>      x_msg_count,
                p_data     =>      x_msg_data
            );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        ROLLBACK TO expire_pricing_attribs;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (   p_count    =>      x_msg_count,
                p_data     =>      x_msg_data
            );

    WHEN OTHERS THEN

        ROLLBACK TO  expire_pricing_attribs;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level
            (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.Add_Exc_Msg
                (   g_pkg_name,
                    l_api_name
                 );
        END IF;

        FND_MSG_PUB.Count_And_Get
            (   p_count    =>      x_msg_count,
                p_data     =>      x_msg_data
             );

END expire_pricing_attribs;


END csi_pricing_attribs_pub;


/
