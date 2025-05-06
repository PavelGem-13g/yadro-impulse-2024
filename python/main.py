import random
import pandas as pd

def compute_Q(a: int, b: int, c: int, d: int) -> int:
    return ((a - b) * (1 + 3 * c) - 4 * d) // 2

test_vectors = []
for _ in range(20):
    a = random.randint(-100, 100)
    b = random.randint(-100, 100)
    c = random.randint(-100, 100)
    d = random.randint(-100, 100)
    q = compute_Q(a, b, c, d)
    test_vectors.append((a, b, c, d, q))

df = pd.DataFrame(test_vectors, columns=["a", "b", "c", "d", "Q_expected"])
