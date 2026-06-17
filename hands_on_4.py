import mysql.connector
import time

# Database Connection
conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="Pooja@91",
    database="hostel_db"
)

cursor = conn.cursor(dictionary=True)

# =====================================================
# VERSION 1 : N+1 PROBLEM
# =====================================================

print("===== VERSION 1 : N+1 PROBLEM =====")

query_count = 0
start_time = time.time()

# Query 1
cursor.execute("SELECT * FROM room_allocations")
allocations = cursor.fetchall()
query_count += 1

results = []

for allocation in allocations:

    resident_id = allocation["resident_id"]

    # One query per allocation
    cursor.execute(
        "SELECT first_name, last_name FROM residents WHERE resident_id=%s",
        (resident_id,)
    )

    resident = cursor.fetchone()
    query_count += 1

    results.append({
        "allocation_id": allocation["allocation_id"],
        "resident_name": resident["first_name"] + " " + resident["last_name"]
    })

end_time = time.time()

print(f"Queries Executed: {query_count}")
print(f"Execution Time: {end_time - start_time:.6f} seconds")

for row in results:
    print(row)

# =====================================================
# VERSION 2 : SINGLE JOIN QUERY
# =====================================================

print("\n===== VERSION 2 : JOIN SOLUTION =====")

query_count = 0
start_time = time.time()

cursor.execute("""
SELECT
    ra.allocation_id,
    r.first_name,
    r.last_name
FROM room_allocations ra
JOIN residents r
ON ra.resident_id = r.resident_id
""")

query_count += 1

results = cursor.fetchall()

end_time = time.time()

print(f"Queries Executed: {query_count}")
print(f"Execution Time: {end_time - start_time:.6f} seconds")

for row in results:
    print({
        "allocation_id": row["allocation_id"],
        "resident_name": row["first_name"] + " " + row["last_name"]
    })

cursor.close()
conn.close()