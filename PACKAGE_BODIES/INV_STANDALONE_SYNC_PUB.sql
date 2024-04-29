--------------------------------------------------------
--  DDL for Package Body INV_STANDALONE_SYNC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_STANDALONE_SYNC_PUB" as
/* $Header: INVSLSPB.pls 120.0.12010000.5 2009/08/19 06:49:56 hjogleka noship $*/

    g_pkg_name CONSTANT VARCHAR2(30) := 'INV_STANDALONE_SYNC_PUB';
    g_debug    NUMBER;
    TYPE adj_txn_tbl_type IS TABLE OF MTL_ADJUSTMENT_TXN_SYNC_V%ROWTYPE INDEX BY BINARY_INTEGER;
    -- Bug 8784314
    TYPE txn_id_tbl_type IS TABLE OF NUMBER;
    TYPE t_genref IS REF CURSOR;

    PROCEDURE print_debug(p_message IN VARCHAR2, p_level IN NUMBER DEFAULT 11) IS
    BEGIN
       IF g_debug IS NULL THEN
          g_debug :=  NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
       END IF;

       IF (g_debug = 1) THEN
          inv_log_util.trace(p_message, g_pkg_name, p_level);
       END IF;
    END;

    FUNCTION Update_RC_Extracted(
             p_api_version        IN         NUMBER
           , p_init_msg_list      IN         VARCHAR2  := FND_API.G_FALSE
           , p_commit             IN         VARCHAR2  := FND_API.G_FALSE
           , x_return_status      OUT NOCOPY VARCHAR2
           , x_msg_count          OUT NOCOPY NUMBER
           , x_msg_data           OUT NOCOPY VARCHAR2
           , p_start_date         IN         VARCHAR2
           , p_end_date           IN         VARCHAR2
           , p_category           IN         VARCHAR2 DEFAULT NULL
           , p_warehouse          IN         VARCHAR2
           , p_document_num       IN         VARCHAR2 DEFAULT NULL
           , p_receipt_num        IN         VARCHAR2
           , p_inventory_item     IN         VARCHAR2 DEFAULT NULL
           , p_rc_extracted       IN         VARCHAR2
           , p_transaction_id     IN         NUMBER   DEFAULT NULL
          ) RETURN VARCHAR2 IS

          l_api_version     CONSTANT NUMBER        :=  1.0;
          l_api_name        CONSTANT VARCHAR2(30)  :=  'Update_RC_Extracted';
          err_msg           VARCHAR2(100) := NULL;
          l_from_date       DATE;
          l_to_date         DATE;
          l_category        VARCHAR2(500);
          l_warehouse       VARCHAR2(30);
          l_document_num    VARCHAR2(30);
          l_receipt_num     VARCHAR2(500);
          l_inventory_item  VARCHAR2(500);
          l_rc_extracted    VARCHAR2(1);
          l_transaction_id  NUMBER;

    BEGIN
          IF NOT FND_API.Compatible_API_Call (  l_api_version, p_api_version ,
                                                l_api_name   , G_PKG_NAME    )
          THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

          IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
          END IF;

          x_return_status := FND_API.G_RET_STS_SUCCESS;
          print_debug('In Update_RC_Extracted');

          IF (g_debug = 1) THEN
              print_debug('In Update_RC_Extracted');
              print_debug('p_from_date      : ' || p_start_date);
              print_debug('p_to_date        : ' || p_end_date);
              print_debug('p_category       : ' || p_category);
              print_debug('p_warehouse      : ' || p_warehouse);
              print_debug('p_document_num   : ' || p_document_num);
              print_debug('p_receipt_num    : ' || p_receipt_num);
              print_debug('p_RC_Extracted   : ' || p_rc_extracted);
              print_debug('p_transaction_id : ' || p_transaction_id);
              print_debug('p_inventory_item : ' || p_inventory_item);
          END IF;

          l_from_date       := to_date(p_start_date);
          l_to_date         := to_date(p_end_date);
          l_category        := p_category;
          l_warehouse       := p_warehouse;
          l_document_num    := p_document_num;
          l_receipt_num     := p_receipt_num;
          l_rc_extracted    := p_rc_extracted;
          l_transaction_id  := p_transaction_id;
          l_inventory_item  := p_inventory_item;


          UPDATE rcv_transactions
          SET    receipt_confirmation_extracted = l_RC_Extracted
          WHERE  transaction_id  IN
                  (SELECT transaction_id
                   FROM   rcv_receipt_confirmation_v
                   WHERE  creation_date BETWEEN l_from_date AND l_to_date
                   AND    category = nvl(l_category, category)
                   AND    warehouse = l_warehouse
                   AND    item = nvl(l_inventory_item, item)
                   AND    document_number = nvl(l_document_num, document_number)
                   AND    receipt = l_receipt_num
                   AND    transaction_id = nvl(l_transaction_id, transaction_id)
                   AND    RC_Extracted IS NULL);

          IF (g_debug = 1) THEN
              print_debug('Updated ' || SQL%ROWCOUNT || ' rows.');
          END IF;

          IF FND_API.To_Boolean( p_commit ) THEN
             COMMIT WORK;
          END IF;

          RETURN 'S';

    EXCEPTION
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           FND_MSG_PUB.Count_And_Get
              (     p_count           =>      x_msg_count       ,
                    p_data            =>      x_msg_data
              );
           IF (g_debug = 1) THEN
              print_debug('API Version Incompatible in the call to Update_RC_Extracted' );
           END IF;
           RETURN 'U';

       WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
           END IF;
           FND_MSG_PUB.Count_And_Get
              (     p_count           =>      x_msg_count       ,
                    p_data            =>      x_msg_data
              );
           IF (g_debug = 1) THEN
              print_debug('Error in Update_RC_Extracted' );
           END IF;
           RETURN 'U';

    END Update_RC_Extracted;


    FUNCTION sync_adjustment_transactions(
           p_api_version                IN         NUMBER
         , p_init_msg_list              IN         VARCHAR2     := FND_API.G_FALSE
         , p_commit                     IN         VARCHAR2     := FND_API.G_FALSE
         , x_return_status              OUT NOCOPY VARCHAR2
         , x_msg_count                  OUT NOCOPY NUMBER
         , x_msg_data                   OUT NOCOPY VARCHAR2
         , p_from_date                  IN         DATE
         , p_to_date                    IN         DATE
         , p_organization_name          IN         VARCHAR2
         , p_category_name              IN         VARCHAR2
         , p_inventory_item             IN         VARCHAR2     DEFAULT NULL
         , p_transaction_type           IN         VARCHAR2     DEFAULT NULL
         , p_transaction_source         IN         VARCHAR2     DEFAULT NULL
         , p_transaction_id             IN         NUMBER       DEFAULT NULL
         , p_extract_flag               IN         VARCHAR2
         ) RETURN VARCHAR2 AS
        l_api_version       CONSTANT NUMBER        :=  1.0;
        l_api_name          CONSTANT VARCHAR2(30)  :=  'sync_adjustment_transactions';

        l_organization_id            NUMBER;
        l_inventory_item_id          NUMBER;
        l_transaction_type_id        NUMBER;
        err_msg                      VARCHAR2(100) := NULL;
        ret_cursor                   INV_STANDALONE_SYNC_PUB.t_genref := NULL;
    BEGIN

        print_debug('sync_adjustment_transactions(Value) Entered');
        IF (g_debug = 1) THEN
          print_debug('param = ' ||p_from_date||','||p_to_date||','||p_organization_name||','||p_category_name||','
                               ||p_inventory_item||','||p_transaction_type||','||p_transaction_source||','||p_transaction_id||','||p_extract_flag);
        END IF;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (  l_api_version, p_api_version ,
                                              l_api_name   , G_PKG_NAME    )
        THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- Check p_init_msg_list
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
        END IF;
        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- Handle Organization Name / Organization Id
        IF  p_organization_name IS NULL THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSE
            BEGIN
              SELECT organization_id
              INTO   l_organization_id
              FROM   org_organization_definitions
              WHERE  organization_name = p_organization_name;
            EXCEPTION
              WHEN OTHERS THEN
                fnd_message.set_name('INV', 'INV_INT_ORGCODE');
                fnd_msg_pub.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END;
        END IF;

        IF (g_debug = 1) THEN
          print_debug('l_org_id = '||l_organization_id);
        END IF;

        -- Handle Item Number / Item Id
        IF  p_inventory_item IS NULL THEN
            l_inventory_item_id := NULL;
        ELSE
            BEGIN
              SELECT inventory_item_id
              INTO   l_inventory_item_id
              FROM   mtl_system_items_kfv
              WHERE  organization_id       = l_organization_id
              AND    concatenated_segments = p_inventory_item;
            EXCEPTION
              WHEN OTHERS THEN
                fnd_message.set_name('INV', 'INV_INT_ITMCODE');
                fnd_msg_pub.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END;
        END IF;

        IF (g_debug = 1) THEN
          print_debug('l_inventory_item_id: '||l_inventory_item_id);
        END IF;

        -- Handle Transaction Type
        IF  p_transaction_type IS NULL THEN
            l_transaction_type_id := NULL;
        ELSE
            BEGIN
              SELECT transaction_type_id
              INTO   l_transaction_type_id
              FROM   mtl_transaction_types
              WHERE  transaction_type_name = p_transaction_type;
            EXCEPTION
              WHEN OTHERS THEN
                fnd_message.set_name('INV', 'INV_INT_TRXTYPCODE');
                fnd_msg_pub.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END;
        END IF;

        IF (g_debug = 1) THEN
          print_debug('l_transaction_type_id: '||l_transaction_type_id);
          print_debug('p_extract_flag: '||p_extract_flag);
        END IF;


        sync_adjustment_transactions2(
            p_api_version                => 1.0
          , x_return_status              => x_return_status
          , x_msg_count                  => x_msg_count
          , x_msg_data                   => x_msg_data
          , p_from_date                  => p_from_date
          , p_to_date                    => p_to_date
          , p_organization_id            => l_organization_id
          , p_category_name              => p_category_name
          , p_inventory_item_id          => l_inventory_item_id
          , p_transaction_type_id        => l_transaction_type_id
          , p_transaction_source         => p_transaction_source
          , p_transaction_id             => p_transaction_id
          , p_extract_flag               => p_extract_flag
          );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF (g_debug = 1) THEN
              print_debug('return status : '|| x_return_status || ' msg_count : ' || x_msg_count);
              print_debug('error : '|| x_msg_data);
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT WORK;
        END IF;

        RETURN x_return_status;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get
            (   p_count             =>      x_msg_count       ,
                p_data              =>      x_msg_data
            );
            RETURN 'E';

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get
            (     p_count           =>      x_msg_count       ,
                  p_data            =>      x_msg_data
            );
            RETURN 'U';
        WHEN OTHERS THEN
            print_debug('In exception');
            RETURN 'U';

    END sync_adjustment_transactions;

    PROCEDURE sync_adjustment_transactions2(
           p_api_version                IN         NUMBER
         , p_init_msg_list              IN         VARCHAR2     := FND_API.G_FALSE
         , p_commit                     IN         VARCHAR2     := FND_API.G_FALSE
         , x_return_status              OUT NOCOPY VARCHAR2
         , x_msg_count                  OUT NOCOPY NUMBER
         , x_msg_data                   OUT NOCOPY VARCHAR2
         , p_from_date                  IN         DATE
         , p_to_date                    IN         DATE
         , p_organization_id            IN         NUMBER
         , p_category_name              IN         VARCHAR2
         , p_inventory_item_id          IN         NUMBER       DEFAULT NULL
         , p_transaction_type_id        IN         NUMBER       DEFAULT NULL
         , p_transaction_source         IN         VARCHAR2     DEFAULT NULL
         , p_transaction_id             IN         NUMBER       DEFAULT NULL
         , p_extract_flag               IN         VARCHAR2
         ) AS

    l_api_version       CONSTANT NUMBER        :=  1.0;
    l_api_name          CONSTANT VARCHAR2(30)  :=  'sync_adjustment_transactions2';

    err_msg                      VARCHAR2(100) := NULL;
    ret_cursor                   INV_STANDALONE_SYNC_PUB.t_genref := NULL;

    l_from_date                  DATE;
    l_to_date                    DATE;
    l_organization_id            NUMBER;
    l_category_name              VARCHAR2(240);
    l_inventory_item_id          NUMBER;
    l_transaction_source         VARCHAR2(240);
    l_transaction_type_id        NUMBER;
    l_transaction_id             NUMBER;
    l_extract_flag               VARCHAR2(1);

    l_txn_detail                 adj_txn_tbl_type;

    stmt                         VARCHAR2(400);
    -- Bug 8784314
    t_txn_id                     txn_id_tbl_type := txn_id_tbl_type();

    BEGIN

        print_debug('sync_adjustment_transactions(id) Entered');

        IF (g_debug = 1) THEN
          print_debug('param = ' ||p_from_date||','||p_to_date||','||p_organization_id||','||p_category_name||','
                               ||p_inventory_item_id||','||p_transaction_type_id||','||p_transaction_source||','||p_transaction_id||','||p_extract_flag);
        END IF;

        --  Standard begin of API savepoint
        SAVEPOINT inv_sync_adj_txn1;
        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (  l_api_version, p_api_version ,
                                              l_api_name   , G_PKG_NAME    )
        THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- Check p_init_msg_list
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
        END IF;
        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        l_from_date                  := p_from_date;
        l_to_date                    := p_to_date;
        l_organization_id            := p_organization_id;
        l_category_name            := p_category_name;
        l_inventory_item_id          := p_inventory_item_id;
        l_transaction_type_id        := p_transaction_type_id;
        l_transaction_source         := p_transaction_source;
        l_extract_flag               := p_extract_flag;

        IF l_organization_id IS NULL OR l_category_name IS NULL OR l_from_date IS NULL OR l_to_date IS NULL THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        stmt :=    'SELECT  * '
                || ' FROM   MTL_ADJUSTMENT_TXN_SYNC_V '
                || ' WHERE  organization_id       = :org '
                || ' AND    Category              = :category '
                || ' AND    Creation_Date      BETWEEN :fr_date AND :to_date ';


        IF  l_inventory_item_id    IS NOT NULL
        THEN
            stmt := stmt || ' AND    Inventory_item_id     = :itemid ';
        END IF;


        IF  l_transaction_type_id  IS NOT NULL
        THEN
            stmt := stmt || ' AND    transaction_type_id   = :txntypeid ';
            stmt := stmt || ' AND    NVL(transaction_source,''@@@'') = NVL(:txnsource, ''@@@'') ';
        END IF;

        IF  l_transaction_id    IS NOT NULL
        THEN
            stmt := stmt || ' AND    transaction_id     = :txnid ';
        END IF;


        IF (g_debug = 1) THEN
          print_debug('stmt = ' || stmt);
          print_debug('bind = ' || l_organization_id  ||','||l_category_name    ||','||l_from_date||','||l_to_date||','
                              || l_inventory_item_id||','||l_transaction_type_id||','||l_transaction_source||','||l_transaction_id);
        END IF;

        IF     l_inventory_item_id    IS NULL
           AND l_transaction_type_id  IS NULL
           AND l_transaction_id       IS NULL
        THEN
            OPEN  ret_cursor FOR stmt USING l_organization_id, l_category_name, l_from_date, l_to_date;

        ELSIF  l_inventory_item_id    IS NOT NULL
           AND l_transaction_type_id  IS NULL
           AND l_transaction_id       IS NULL
        THEN
            OPEN  ret_cursor FOR stmt USING l_organization_id, l_category_name, l_from_date, l_to_date, l_inventory_item_id;

        ELSIF  l_inventory_item_id    IS NULL
           AND l_transaction_type_id  IS NOT NULL
           AND l_transaction_id       IS NULL
        THEN
            OPEN  ret_cursor FOR stmt USING l_organization_id, l_category_name, l_from_date, l_to_date,
                                            l_transaction_type_id, l_transaction_source;

        ELSIF  l_inventory_item_id    IS NOT NULL
           AND l_transaction_type_id  IS NOT NULL
           AND l_transaction_id       IS NULL
        THEN
            OPEN  ret_cursor FOR stmt USING l_organization_id, l_category_name, l_from_date, l_to_date,
                                            l_inventory_item_id, l_transaction_type_id, l_transaction_source;
        ELSIF  l_inventory_item_id    IS NULL
           AND l_transaction_type_id  IS NULL
           AND l_transaction_id       IS NOT NULL
        THEN
            OPEN  ret_cursor FOR stmt USING l_organization_id, l_category_name, l_from_date, l_to_date, l_transaction_id;

        ELSIF  l_inventory_item_id    IS NOT NULL
           AND l_transaction_type_id  IS NULL
           AND l_transaction_id       IS NOT NULL
        THEN
            OPEN  ret_cursor FOR stmt USING l_organization_id, l_category_name, l_from_date, l_to_date, l_inventory_item_id, l_transaction_id;

        ELSIF  l_inventory_item_id    IS NULL
           AND l_transaction_type_id  IS NOT NULL
           AND l_transaction_id       IS NOT NULL
        THEN
            OPEN  ret_cursor FOR stmt USING l_organization_id, l_category_name, l_from_date, l_to_date,
                                            l_transaction_type_id, l_transaction_source, l_transaction_id;

        ELSIF  l_inventory_item_id    IS NOT NULL
           AND l_transaction_type_id  IS NOT NULL
           AND l_transaction_id       IS NOT NULL
        THEN
            OPEN  ret_cursor FOR stmt USING l_organization_id, l_category_name, l_from_date, l_to_date,
                                            l_inventory_item_id, l_transaction_type_id, l_transaction_source, l_transaction_id;
        END IF;

        FETCH ret_cursor BULK COLLECT INTO l_txn_detail;
        CLOSE ret_cursor;

        -- Bug 8784314, using scalar array instead of table of records for backward compatibility with 9i/10g..
        t_txn_id.extend(l_txn_detail.last - l_txn_detail.first + 1);
        FOR i IN l_txn_detail.first .. l_txn_detail.last LOOP
          t_txn_id(i) := l_txn_detail(i).transaction_number;
        END LOOP;

        IF (g_debug = 1) THEN
          print_debug('Updating MMT to set transaction_extracted = ' || l_extract_flag);
        END IF;

        -- Mark transactions with Synchronization Status.
        -- Bug 8784314, replacing l_txn_detail(i).transaction_number by t_txn_id(i).

        FORALL i IN l_txn_detail.first .. l_txn_detail.last
        UPDATE mtl_material_transactions
        SET    transaction_extracted = l_extract_flag
        WHERE  transaction_id        = t_txn_id(i);

        IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT WORK;
        END IF;

        l_txn_detail.DELETE;
        t_txn_id.DELETE;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO inv_sync_adj_txn1;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
            (   p_count             =>      x_msg_count       ,
                p_data              =>      x_msg_data
            );
          l_txn_detail.DELETE;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO inv_sync_adj_txn1;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get
            (     p_count           =>      x_msg_count       ,
                  p_data            =>      x_msg_data
            );
          l_txn_detail.DELETE;

        WHEN OTHERS THEN
          ROLLBACK TO inv_sync_adj_txn1;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get
            (     p_count           =>      x_msg_count       ,
                  p_data            =>      x_msg_data
            );
          l_txn_detail.DELETE;

    END sync_adjustment_transactions2;


END  inv_standalone_sync_pub;

/
