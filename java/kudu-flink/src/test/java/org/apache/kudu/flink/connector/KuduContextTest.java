/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.apache.kudu.flink.connector;

import java.util.Map;
import org.apache.commons.collections.map.HashedMap;
import org.apache.kudu.Type;
<<<<<<< HEAD
import org.apache.kudu.client.BaseKuduTest;
import org.junit.Assert;
import org.junit.Test;

public class KuduContextTest extends BaseKuduTest {
=======
import org.apache.kudu.flink.KuduClusterTest;
import org.junit.Assert;
import org.junit.Test;

public class KuduContextTest extends KuduClusterTest {
>>>>>>> origin/KUDU-2273

    @Test
    public void testTableCreationAndDeletion() throws Exception {
        KuduContext client = new KuduContext(obtainTable("testing", true));
        Assert.assertTrue("table dont exists", client.tableExists());
        Assert.assertTrue("table not eliminated", client.deleteTable());
        Assert.assertFalse("table exists", client.tableExists());
    }

    @Test(expected = UnsupportedOperationException.class)
    public void testTableCreationError() throws Exception {
        new KuduContext(obtainTable("testing", false));
    }

<<<<<<< HEAD
    @Test
    public void testTableWrite() throws Exception {
        KuduContext client = new KuduContext(obtainTable("testing", true));
        for (int i=0; i<10; i++) {
            Assert.assertTrue("write not done", client.writeRow(createRow(i)));
        }
    }

=======
>>>>>>> origin/KUDU-2273
    private KuduRow createRow(Integer key) {
        Map<String, Object> map = new HashedMap();
        map.put("key", key);
        map.put("value", "value"+key);
        return new KuduRow(map);
    }

    private static KuduTableInfo obtainTable(String tableName, boolean createIfNotExists) {
        return KuduTableInfo.Builder
<<<<<<< HEAD
                .create(masterAddresses, tableName)
=======
                .create(hostsCluster, tableName)
>>>>>>> origin/KUDU-2273
                .mode(KuduTableInfo.Mode.UPSERT)
                .createIfNotExist(createIfNotExists)
                .addColumn(KuduColumnInfo.Builder.create("key", Type.INT32).key(true).rangeKey(true).build())
                .addColumn(KuduColumnInfo.Builder.create("value", Type.STRING).build())
                .build();
    }

}
