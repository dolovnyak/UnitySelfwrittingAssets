using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour
{
    [SerializeField] private float speed = 2;
    [SerializeField] private float speedUp = 4;
    [SerializeField] private float cameraSensevity = 100;
    private float rotationX = 0f;
    private float rotationY = 0f;

    void Update()
    {
        Rotation();
        Move();
    }

    void Move()
    {
        var currentSpeed = speed;
        if (Input.GetKey(KeyCode.LeftShift) || Input.GetKey(KeyCode.RightShift))
        {
            currentSpeed *= speedUp;
        }

        var axisY = 0.0f;
        if (Input.GetKey(KeyCode.Q)) { axisY = -1.0f; }
        if (Input.GetKey(KeyCode.E)) { axisY = 1.0f; }

        transform.position += transform.forward * currentSpeed * Input.GetAxis("Vertical") * Time.deltaTime;
        transform.position += transform.right * currentSpeed * Input.GetAxis("Horizontal") * Time.deltaTime;
        transform.position += transform.up * currentSpeed * axisY * Time.deltaTime;
    }

    void Rotation()
    {
        rotationX += Input.GetAxis("Mouse X") * cameraSensevity * Time.deltaTime;
        rotationY += Input.GetAxis("Mouse Y") * cameraSensevity * Time.deltaTime;
        rotationY = Mathf.Clamp(rotationY, -90f, 90f);
        transform.localRotation = Quaternion.AngleAxis(rotationX, Vector3.up);
        transform.localRotation *= Quaternion.AngleAxis(rotationY, Vector3.left);
    }
}
